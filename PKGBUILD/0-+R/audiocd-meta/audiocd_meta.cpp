// g++ -O2 -std=c++17 audiocd_meta.cpp -o audiocd-meta $( pkg-config --cflags --libs libcurl libdiscid libxml-2.0 )

#include <discid/discid.h>
#include <curl/curl.h>
#include <libxml/parser.h>
#include <libxml/xpath.h>
#include <libxml/xpathInternals.h>

#include <fstream>
#include <filesystem>
#include <iostream>
#include <string>

namespace fs = std::filesystem;

bool STDOUT = false;
std::string DIR_ID, DISCID;

static const char *USER_AGENT = "MyDiscIdApp/1.0 ( you@example.com )";
static const char *MB_NS = "http://musicbrainz.org/ns/mmd-2.0#";

// --- libcurl write callback ---
static size_t curl_write_cb(void *contents, size_t size, size_t nmemb, void *userp) {
    size_t total = size * nmemb;
    static_cast<std::string *>(userp)->append(static_cast<char *>(contents), total);
    return total;
}

static bool http_get(const std::string &url, std::string &response, std::string &err) {
    CURL *curl = curl_easy_init();
    if (!curl) {
        err = "curl_easy_init failed";
        return false;
    }

    curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
    curl_easy_setopt(curl, CURLOPT_USERAGENT, USER_AGENT);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, curl_write_cb);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response);
    curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
    curl_easy_setopt(curl, CURLOPT_TIMEOUT, 15L);

    CURLcode res = curl_easy_perform(curl);
    long http_code = 0;
    curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &http_code);
    curl_easy_cleanup(curl);

    if (res != CURLE_OK) {
        err = curl_easy_strerror(res);
        return false;
    }
    if (http_code != 200) {
        err = "HTTP status " + std::to_string(http_code) + ": " + response;
        return false;
    }
    return true;
}

// Helper: evaluate an XPath expression relative to a context node and
// return the trimmed string content of the first match, or "" if none.
static std::string xpath_string(xmlXPathContextPtr ctx, xmlNodePtr node, const char *expr) {
    ctx->node = node;
    xmlXPathObjectPtr obj = xmlXPathEvalExpression(BAD_CAST expr, ctx);
    std::string result;
    if (obj && obj->nodesetval && obj->nodesetval->nodeNr > 0) {
        xmlChar *text = xmlNodeGetContent(obj->nodesetval->nodeTab[0]);
        if (text) {
            result = reinterpret_cast<const char *>(text);
            xmlFree(text);
        }
    }
    if (obj) xmlXPathFreeObject(obj);
    return result;
}

// Helper: get a nodeset for an XPath expression (caller must free with xmlXPathFreeObject)
static xmlXPathObjectPtr xpath_nodes(xmlXPathContextPtr ctx, xmlNodePtr node, const char *expr) {
    ctx->node = node;
    return xmlXPathEvalExpression(BAD_CAST expr, ctx);
}

static void print_release(xmlXPathContextPtr ctx, xmlNodePtr release_node) {
    std::string data = xpath_string(ctx, release_node, "mb:title") +"\n"                                           // album
                     + xpath_string(ctx, release_node, "mb:artist-credit/mb:name-credit/mb:artist/mb:name") +"\n"; // artist

    xmlXPathObjectPtr tracks = xpath_nodes(ctx, release_node, "mb:medium-list/mb:medium/mb:track-list/mb:track");  // tracks
    if (tracks && tracks->nodesetval && tracks->nodesetval->nodeNr > 0) {
        for (int i = 0; i < tracks->nodesetval->nodeNr; ++i) {
            xmlNodePtr track_node = tracks->nodesetval->nodeTab[i];
            std::string Title  = xpath_string(ctx, track_node, "mb:recording/mb:title");
            std::string length = xpath_string(ctx, track_node, "mb:length");
            if (length.empty()) length = xpath_string(ctx, track_node, "mb:recording/mb:length");
            int Time = (std::stoi(length) + 500) / 1000;
 
            data += std::to_string(Time) +" "+ Title +"\n";
        }
    }
    if (tracks) xmlXPathFreeObject(tracks);
    
    std::error_code error;
    fs::create_directory(DIR_ID, error);
    if (error) {
        std::cerr
            << "Failed: create directory: " << DIR_ID << '\n'
            << error.message() <<  '\n';
        return;
    }
    
    std::ofstream file_id(DIR_ID +"/data");
    if (!file_id) {
        std::cerr << "Failed: create file: " << DIR_ID +"/data" << '\n';
        return;
    }
    
    file_id << data;
    
    if (STDOUT) {
        std::cout
            << "\nExample DISCID: " << DISCID << "\n\n"
            << data;
        return;
    }
    
    std::cout << DISCID << '\n';
}

int main(int argc, char **argv) {
    if (argc > 1) {
        std::string argv1 = argv[1];
        DISCID = "I5l9cCSFccLKFEKS.7wqSZAorPU-";
        if (argv1 == "-h") {
            std::cerr
                << "\nFetch Audio CD album, artist and track list from MusicBrainZ.\n\n"

                << "Usage: " << argv[0] << " [DISCID]\n"
                << "          default: calculate discid from current CD/DVD\n"
                << "  x       (any invalid discid) example discid: " << DISCID << '\n' // Nirvana - Nevermind
                << "  DISCID  MusicBrainZ discid\n\n";
            return 0;
        }
        
        STDOUT = true;
        if (argv1.size() == 28) DISCID = argv1;
    } else {
        DiscId *disc = discid_new();
        if (discid_read_sparse(disc, nullptr, 0) == 0) {
            std::cerr << "Error reading disc: " << discid_get_error_msg(disc) << "\n";
            discid_free(disc);
            return 1;
        }

        DISCID = discid_get_id(disc);
        discid_free(disc);
        if (DISCID.empty()) {
            std::cerr << "Failed: no discid." << "\n";
            return 1;
        }
    }
    
    DIR_ID = "/srv/http/data/audiocd/"+ DISCID;
    if (fs::is_directory(DIR_ID)) {
        if (STDOUT) std::cout << "Example DISCID: ";
        std::cout << DISCID << '\n';
        return 0;
    }
    
    curl_global_init(CURL_GLOBAL_DEFAULT);

    std::string url = "https://musicbrainz.org/ws/2/discid/"+ DISCID +"?inc=artist-credits+recordings";
    std::string response, err;
    bool ok = http_get(url, response, err);

    if (!ok) {
        std::cerr << "Failed: MusicBrainz lookup." << err << "\n";
        curl_global_cleanup();
        return 1;
    }

    xmlDocPtr doc = xmlReadMemory(response.c_str(), static_cast<int>(response.size()),
                                   "response.xml", nullptr, 0);
    if (!doc) {
        std::cerr << "Failed: parse XML response.\n";
        curl_global_cleanup();
        return 1;
    }

    xmlXPathContextPtr ctx = xmlXPathNewContext(doc);
    xmlXPathRegisterNs(ctx, BAD_CAST "mb", BAD_CAST MB_NS);

    xmlXPathObjectPtr releases = xmlXPathEvalExpression(
        BAD_CAST "/mb:metadata/mb:disc/mb:release-list/mb:release", ctx);

    if (!releases || !releases->nodesetval || releases->nodesetval->nodeNr == 0) {
        std::cerr << "Failed: Data not found.";
        return 1;
    }
    
    print_release(ctx, releases->nodesetval->nodeTab[0]);

    if (releases) xmlXPathFreeObject(releases);
    xmlXPathFreeContext(ctx);
    xmlFreeDoc(doc);
    xmlCleanupParser();
    curl_global_cleanup();

    return 0;
}
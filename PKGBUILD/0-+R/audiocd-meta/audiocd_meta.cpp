// g++ -O2 -std=c++17 audiocd_meta.cpp -o audiocd-meta $( pkg-config --cflags --libs libcurl libdiscid libxml-2.0 )

#include <discid/discid.h>
#include <curl/curl.h>
#include <libxml/parser.h>
#include <libxml/xpath.h>
#include <libxml/xpathInternals.h>

#include <fstream>
#include <sstream>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>

namespace fs = std::filesystem;

std::string
    DIR_ID,
    GDB_API   = "http://gnudb.gnudb.org/~cddb/cddb.cgi?cmd=",
    GDB_DISCID,  // GnuDB / FreeDB / CDDB disc ID (8 hex chars)
    GDB_PARAM = "&hello=owner+rAudio+rAudio+1&proto=6",
    GDB_URL,
    MBZ_API   = "https://musicbrainz.org/ws/2/discid/",
    MBZ_DISCID,     // MusicBrainz disc ID (28 chars, base64-ish)
    MBZ_PARAM = "?inc=artist-credits+recordings",
    MBZ_URL;
static const char
    *MBZ_UA   = "MyDiscIdApp/1.0 ( you@example.com )",
    *MBZ_NS   = "http://musicbrainz.org/ns/mmd-2.0#";
int
    FIRST_TRACK     = 1,
    LAST_TRACK      = 0,
    LEADOUT_SECTORS = 0;
    
std::vector<int> TRACK_OFFSETS;


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
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, curl_write_cb);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response);
    curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
    curl_easy_setopt(curl, CURLOPT_TIMEOUT, 15L);
    if (url.rfind("https://musicbrainz", 0) == 0) curl_easy_setopt(curl, CURLOPT_USERAGENT, MBZ_UA);

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

// ---------------------------------------------------------------------
// Disc reading: one discid_read_sparse() call feeds BOTH ID schemes.
// ---------------------------------------------------------------------
static bool read_disc_ids(std::string &err) {
    DiscId *disc = discid_new();
    if (discid_read_sparse(disc, nullptr, 0) == 0) {
        err = discid_get_error_msg(disc);
        discid_free(disc);
        return false;
    }

    const char *mb_id    = discid_get_id(disc);
    const char *gnudb_id = discid_get_freedb_id(disc); // same TOC, CDDB-style checksum

    MBZ_DISCID    = mb_id    ? mb_id    : "";
    GDB_DISCID = gnudb_id ? gnudb_id : "";

    FIRST_TRACK     = discid_get_first_track_num(disc);
    LAST_TRACK      = discid_get_last_track_num(disc);
    LEADOUT_SECTORS = discid_get_sectors(disc);

    TRACK_OFFSETS.clear();
    for (int t = FIRST_TRACK; t <= LAST_TRACK; ++t) {
        TRACK_OFFSETS.push_back(discid_get_track_offset(disc, t));
    }

    discid_free(disc);

    if (MBZ_DISCID.empty() && GDB_DISCID.empty()) {
        err = "no discid computed";
        return false;
    }
    return true;
}

// ---------------------------------------------------------------------
// XPath helpers (MusicBrainz XML response)
// ---------------------------------------------------------------------
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

static xmlXPathObjectPtr xpath_nodes(xmlXPathContextPtr ctx, xmlNodePtr node, const char *expr) {
    ctx->node = node;
    return xmlXPathEvalExpression(BAD_CAST expr, ctx);
}

static void write_data(const std::string &data) {
    if (DIR_ID.empty()) {
        std::cout << data;
        return;
    }

    std::error_code error;
    fs::create_directory(DIR_ID, error);
    if (error) {
        std::cerr
            << "Failed: create directory " << DIR_ID << '\n'
            << error.message() << '\n';
        return;
    }
    
    std::ofstream file(DIR_ID + "/data");
    if (!file) {
        std::cerr << "Failed: create file " << DIR_ID + "/data" << '\n';
        return;
    }
    file << data;

    std::cout << MBZ_DISCID << '\n';
}

static void print_release_musicbrainz(xmlXPathContextPtr ctx, xmlNodePtr release_node) {
    std::string data = xpath_string(ctx, release_node, "mb:title") + "\n"
                      + xpath_string(ctx, release_node, "mb:artist-credit/mb:name-credit/mb:artist/mb:name") + "\n";

    xmlXPathObjectPtr tracks = xpath_nodes(ctx, release_node, "mb:medium-list/mb:medium/mb:track-list/mb:track");
    if (tracks && tracks->nodesetval && tracks->nodesetval->nodeNr > 0) {
        for (int i = 0; i < tracks->nodesetval->nodeNr; ++i) {
            xmlNodePtr track_node = tracks->nodesetval->nodeTab[i];
            std::string title  = xpath_string(ctx, track_node, "mb:recording/mb:title");
            std::string length = xpath_string(ctx, track_node, "mb:length");
            if (length.empty()) length = xpath_string(ctx, track_node, "mb:recording/mb:length");
            int time_s = (std::stoi(length) + 500) / 1000;

            data += std::to_string(time_s) + " " + title + "\n";
        }
    }
    if (tracks) xmlXPathFreeObject(tracks);

    write_data(data);
}

static bool lookup_musicbrainz(std::string &err_out) {
    MBZ_URL = MBZ_API + MBZ_DISCID + MBZ_PARAM;
    std::string response, err;
    if (!http_get(MBZ_URL, response, err)) {
        err_out = err;
        return false;
    }

    xmlDocPtr doc = xmlReadMemory(response.c_str(), static_cast<int>(response.size()),
                                   "response.xml", nullptr, 0);
    if (!doc) {
        err_out = "Failed: parse MusicBrainz XML response.";
        return false;
    }

    xmlXPathContextPtr ctx = xmlXPathNewContext(doc);
    xmlXPathRegisterNs(ctx, BAD_CAST "mb", BAD_CAST MBZ_NS);

    xmlXPathObjectPtr releases = xmlXPathEvalExpression(
        BAD_CAST "/mb:metadata/mb:disc/mb:release-list/mb:release", ctx);

    bool found = releases && releases->nodesetval && releases->nodesetval->nodeNr > 0;
    if (found) {
        print_release_musicbrainz(ctx, releases->nodesetval->nodeTab[0]);
    } else {
        err_out = "no release found for this disc";
    }

    if (releases) xmlXPathFreeObject(releases);
    xmlXPathFreeContext(ctx);
    xmlFreeDoc(doc);
    return found;
}

// ---------------------------------------------------------------------
// GnuDB (legacy CDDB protocol) fallback
// ---------------------------------------------------------------------
// Kept for any command arguments (e.g. free-text submissions) that might
// need proper percent-encoding; the query/read commands above intentionally
// use literal '+' separators instead (see gnudb_query/gnudb_read).
[[maybe_unused]] static std::string url_encode(const std::string &s) {
    CURL *curl = curl_easy_init();
    char *out = curl_easy_escape(curl, s.c_str(), static_cast<int>(s.size()));
    std::string result = out ? out : s;
    if (out) curl_free(out);
    curl_easy_cleanup(curl);
    return result;
}

// Splits a CDDB multi-line response body into individual lines.
static std::vector<std::string> split_lines(const std::string &text) {
    std::vector<std::string> lines;
    std::istringstream iss(text);
    std::string line;
    while (std::getline(iss, line)) {
        if (!line.empty() && line.back() == '\r') line.pop_back();
        lines.push_back(line);
    }
    return lines;
}

// A single "category discid title" match line from a query response.
struct GnudbMatch {
    std::string category;
    std::string discid;
    std::string title;
};

static bool gnudb_query(std::vector<GnudbMatch> &matches, std::string &err_out) {
    // cmd=cddb+query+<discid>+<ntrks>+<off1>+<off2>+...+<total_seconds>
    // Build the command with literal '+' separators (matching GnuDB's own
    // documented example) rather than percent-encoding spaces - some CDDB
    // CGI gateways are picky about this.
    std::ostringstream cmd;
    cmd << "cddb+query+" << GDB_DISCID << "+" << TRACK_OFFSETS.size();
    for (int off : TRACK_OFFSETS) cmd << "+" << off;
    cmd << "+" << (LEADOUT_SECTORS / 75); // total playing time in seconds

    GDB_URL = GDB_API + cmd.str() + GDB_PARAM;

    std::string response, err;
    if (!http_get(GDB_URL, response, err)) {
        err_out = err;
        return false;
    }
    
    auto lines = split_lines(response);
    if (lines.empty()) {
        err_out = "empty response from GnuDB";
        return false;
    }

    // First line status codes: 200 = exact match, 211 = multiple close
    // matches (one per following line, terminated by "."), 202/403/... = no match.
    std::istringstream first(lines[0]);
    int code = 0;
    first >> code;

    if (code == 200) {
        // 200 category discid title
        std::string rest;
        std::getline(first, rest);
        std::istringstream rs(rest);
        GnudbMatch m;
        rs >> m.category >> m.discid;
        std::getline(rs, m.title);
        if (!m.title.empty() && m.title[0] == ' ') m.title.erase(0, 1);
        matches.push_back(m);
        return true;
    }

    if (code == 210) {
        for (size_t i = 1; i < lines.size(); ++i) {
            if (lines[i] == ".") break;
            std::istringstream ls(lines[i]);
            GnudbMatch m;
            ls >> m.category >> m.discid;
            std::getline(ls, m.title);
            if (!m.title.empty() && m.title[0] == ' ') m.title.erase(0, 1);
            matches.push_back(m);
        }
        return !matches.empty();
    }

    err_out = "no match found (code " + std::to_string(code) + ")";
    return false;
}

static bool gnudb_read(const GnudbMatch &match, std::string &data_out, std::string &err_out) {
    std::ostringstream cmd;
    cmd << "cddb+read+" << match.category << "+" << match.discid;

    GDB_URL = GDB_API + cmd.str() + GDB_PARAM;

    std::string response, err;
    if (!http_get(GDB_URL, response, err)) {
        err_out = err;
        return false;
    }

    auto lines = split_lines(response);
    if (lines.empty()) {
        err_out = "empty response from GnuDB";
        return false;
    }

    int code = 0;
    std::istringstream(lines[0]) >> code;
    if (code != 210) {
        err_out = "read failed (code " + std::to_string(code) + ")";
        return false;
    }

    std::string artist, album;
    std::vector<std::string> track_titles;

    for (size_t i = 1; i < lines.size(); ++i) {
        const std::string &line = lines[i];
        if (line == ".") break;

        if (line.rfind("DTITLE=", 0) == 0) {
            std::string val = line.substr(7);
            auto sep = val.find(" / ");
            if (sep != std::string::npos) {
                artist = val.substr(0, sep);
                album  = val.substr(sep + 3);
            } else {
                album = val;
            }
        } else if (line.rfind("TTITLE", 0) == 0) {
            auto eq = line.find('=');
            if (eq != std::string::npos) {
                size_t idx = std::stoul(line.substr(6, eq - 6));
                if (idx >= track_titles.size()) track_titles.resize(idx + 1);
                track_titles[idx] += line.substr(eq + 1); // TTITLEn may be continued across lines
            }
        }
    }

    std::string data = album + "\n" + artist + "\n";
    for (size_t i = 0; i < track_titles.size(); ++i) {
        int start = TRACK_OFFSETS[i];
        int end   = (i + 1 < TRACK_OFFSETS.size()) ? TRACK_OFFSETS[i + 1] : LEADOUT_SECTORS;
        int time_s = (end - start) / 75; // frames -> seconds
        data += std::to_string(time_s) + " " + track_titles[i] + "\n";
    }

    data_out = data;
    return true;
}

static bool lookup_gnudb(std::string &err_out) {
    std::vector<GnudbMatch> matches;
    if (!gnudb_query(matches, err_out)) return false;

    // Take the first match; a real client might prompt the user when
    // gnudb_query() returns more than one (code 211) candidate.
    std::string data;
    if (!gnudb_read(matches[0], data, err_out)) return false;

    write_data(data);
    return true;
}

int main(int argc, char **argv) {
    if (argc > 1) { // help or example
        std::string argv1   = argv[1];
        std::string example = "I5l9cCSFccLKFEKS.7wqSZAorPU-"; // example: Nirvana - Nevermind
        if (argv1 == "-h") {
            std::cerr
                << "\nFetch Audio CD album, artist and track list.\n\n"
                << "Usage: " << argv[0] << " [DISCID]\n"
                << "            default: calculate discid from current CD/DVD\n"
                << "  DISCID    MusicBrainZ discid (no GnuDB fallback)\n"
                << "  x         example: " << example << "\n\n";
            return 0;
        }

        if (argv1.size() == 28) {
            MBZ_DISCID = argv1;
        } else {
            MBZ_DISCID = example;
            std::cout << "Example: " << MBZ_DISCID << "\n\n";
        }

        curl_global_init(CURL_GLOBAL_DEFAULT);
        std::string err;
        if (!lookup_musicbrainz(err)) {
            std::cerr
                << "Not found:\n"
                << MBZ_URL << "\n"
                << err << "\n\n";
            curl_global_cleanup();
            return 1;
        }
        curl_global_cleanup();
        return 0;
    }

    std::string err;
    if (!read_disc_ids(err)) {
        std::cerr << "Failed: read disc: " << err << "\n";
        return 1;
    }

    DIR_ID = "/srv/http/data/audiocd/" + MBZ_DISCID;
    if (fs::is_directory(DIR_ID)) { // already exists
        std::cout << MBZ_DISCID << '\n';
        return 0;
    }

    curl_global_init(CURL_GLOBAL_DEFAULT);

    std::string mb_err;
    if (!lookup_musicbrainz(mb_err)) {
        std::string gnudb_err;
        if (!lookup_gnudb(gnudb_err)) {
            std::cerr
                << "Not found:\n\n"
                << "MusicBrainz:\n"
                << MBZ_URL << "\n"
                << mb_err << "\n\n"
                << "GnuDB:\n"
                << GDB_URL << "\n"
                << gnudb_err << "\n\n";
            curl_global_cleanup();
            return 1;
        }
    }

    curl_global_cleanup();
    return 0;
}
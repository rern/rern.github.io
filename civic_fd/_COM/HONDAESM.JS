function FSL(code, name) {
    this.Code = code;
    this.Name = name;
}
function FDL(code, model, type) {
    this.Code = code;
    this.Model = model;
    this.Type = type;
}
function GetCookie(strName) {
    var strCookie = document.cookie;
    var strKey, strVal;
    var n, nPos, nSta, nEnd;
    nPos = 0;
    while (nPos < strCookie.length) {
        while (nPos < strCookie.length) {
            if (strCookie.charAt(nPos) != " ") {
                break;
            }
            ++nPos;
        }
        if (nPos >= strCookie.length) {
            break;
        }
        nSta = strCookie.indexOf("=", nPos);
        if (nSta < 0) {
            break;
        }
        strKey = strCookie.substring(nPos, nSta);
        while (++nSta < strCookie.length) {
            if (strCookie.charAt(nPos) != " ") {
                break;
            }
        }
        if (nSta >= strCookie.length) {
            break;
        }
        nEnd = strCookie.indexOf(";", nSta);
        if (nEnd < 0) {
            strVal = strCookie.substring(nSta);
        } else {
            strVal = strCookie.substring(nSta, nEnd);
        }
        if (strName == strKey) {
            return (strVal);
        }
        if (nEnd < 0) {
            break;
        }
        nPos = nEnd + 1;
    }
    return ("");
}
function SetCookie(strName, strVal, fTmp) {
    var strBuf;
    var timLim = new Date;
    timLim.setYear(timLim.getYear() + 10);
    strBuf = strName + "=" + strVal + ";";
    if ((typeof (fTmp) == "undefined") || !fTmp) {
        strBuf += "Expires=" + timLim.toGMTString() + ";";
    }
    document.cookie = strBuf;
}
function ChangeLang(fSub) {
    var strLang, strPath;
    var wnd;
    if (gESM.subSel.length != 2) {
        gESM.subSel = "00";
    }
    strLang = gESM.Lng[gESM.lngSel].Code + gESM.subSel;
    if (fSub) {
        strPath = "../../../";
        wnd = parent;
    } else {
        strPath = "./";
        wnd = window;
    }
    wnd.SetCookie("EsmLang", strLang + gESM.mySel);
    if (fSub) {
        wnd.location.reload();
    } else {
        wnd.F10.location = strPath + strLang + "/HTML/CTL/ESMTITLE.HTML";
        wnd.F11.location = strPath + strLang + "/HTML/CTL/ESMSELCT.HTML";
        wnd.F12.location = strPath + strLang + "/HTML/CTL/ESMBLANK.HTML";
    }
}
function FS5(id, text) {
    var data = new Array;
    data.id = id;
    data.Text = text;
    return (data);
}
function dbKeyToHtmlFile(path, dbKey) {
    return (path + dbKey.substr(5, 2) + "/" + dbKey + ".HTML");
}
function LoadStr(strID) {
    var strBuf, strMsg;
    var nPos, nSta;
    var i;
    strBuf = null;
    for (i = 0; i < gMSG.length; ++i) {
        if (gMSG[i].id == strID) {
            strBuf = gMSG[i].Text;
            break;
        }
    }
    if (strBuf == null) {
        alert("Undefined Message-ID:" + strID);
        return ("");
    }
    strMsg = "";
    nSta = 0;
    nPos = strBuf.indexOf("\\", nSta);
    while (nPos >= 0) {
        strMsg += strBuf.substring(nSta, nPos);
        switch (strBuf.charAt(nPos + 1)) {
        case 'b':
            strMsg += '\b';
            break;
        case 'f':
            strMsg += '\f';
            break;
        case 'n':
            strMsg += '\n';
            break;
        case 'r':
            strMsg += '\r';
            break;
        case 't':
            strMsg += '\t';
            break;
        case '\'':
            strMsg += '\'';
            break;
        case '"':
            strMsg += '"';
            break;
        case '\\':
            strMsg += '\\';
            break;
        default:
            strMsg += strBuf.charAt(nPos + 1);
            break;
        }
        nSta = nPos + 2;
        nPos = strBuf.indexOf("\\", nSta);
    }
    strMsg += strBuf.substr(nSta);
    return (strMsg);
}
function FormatStr(strID) {
    var strMsg, strBuf;
    var nPos, nSta, arg;
    strBuf = LoadStr(strID);
    strMsg = "";
    nSta = 0;
    nPos = strBuf.indexOf("$", nSta);
    while (nPos >= 0) {
        strMsg += strBuf.substring(nSta, nPos);
        arg = strBuf.charAt(nPos + 1);
        if (isFinite(arg)) {
            if (arg < FormatStr.arguments.length) {
                strMsg += FormatStr.arguments[arg];
            } else {
                alert("FormatStr: Undefined argument '" + strBuf.substr(nPos, 2) + "'(at " + (nPos + 1) + "):");
                break;
            }
        } else {
            strMsg += arg;
        }
        nSta = nPos + 2;
        nPos = strBuf.indexOf("$", nSta);
    }
    strMsg += strBuf.substr(nSta);
    return (strMsg);
}

#!/usr/bin/env dub
/+ dub.sdl:
dependency "dxml" version="~>0.4.3"
+/

import std.file;
import std.algorithm;
import std.path;
import std.stdio;
import std.json;
import std.range;
import std.format;
import std.typecons;
import std.array;
import std.conv;
import std.datetime;
import std.string;
import std.getopt;

import dxml.writer;
import dxml.util;

bool localhost;

static immutable RELIABLE_GATEWAYS = [
    "https://cloudflare-ipfs.com/ipfs/%s",
    "https://dweb.link/ipfs/%s",
    "https://ipfs.io/ipfs/%s",
];

static immutable LOCALHOST_GATEWAY = "http://localhost:8080/ipfs/%s";

struct Metadata {
    this(string filename)
    {
        auto json = parseJSON(readText(filename));

        // get object, if array
        if (json.type == JSONType.array)
            json = json.array[0];

        if ("Title" in json && json["Title"].type == JSONType.string)
            title = json["Title"].str;
        else if ("FileName" in json && json["FileName"].type == JSONType.string)
            title = json["FileName"].str;

        if ("Album" in json && json["Album"].type == JSONType.string)
            album = json["Album"].str;
        if ("Artist" in json && json["Artist"].type == JSONType.string)
            artist = json["Artist"].str;
        if ("Genre" in json && json["Genre"].type == JSONType.string)
            genre = json["Genre"].str;
        if ("Track" in json && json["Track"].type == JSONType.integer)
            trackNo = json["Track"].integer;
        if ("Comment-xxx" in json && json["Comment-xxx"].type == JSONType.string)
            infoLink = json["Comment-xxx"].str;
        if ("Duration" in json && json["Duration"].type == JSONType.string)
        {
            auto durationStr = json["Duration"].str;
            durationStr = durationStr.stripRight(" (approx)");

            auto splitDur = durationStr.split(":");
            if (splitDur.length == 3)
                duration = dur!"hours"(splitDur[0].to!long)
                    + dur!"minutes"(splitDur[1].to!long)
                    + dur!"seconds"(splitDur[2].to!long);
        }

        hash = baseName(filename);
    }

    string title;
    string album;
    string artist;
    string genre;
    string infoLink;
    ulong trackNo;
    Duration duration;

    string hash;
}

void writeM3U(string filename, Metadata[] files)
{
    auto m3uFile = new File(filename, "w");
    scope(exit) m3uFile.close();

    m3uFile.writeln("#EXTM3U\n");

    foreach (Metadata m; files)
    {
        m3uFile.write("#EXTINF:-1,");

        if (m.title)
            m3uFile.writeln(m.title);
        else
            assert(0, "Can't get name!");

        if (m.album)
            m3uFile.writeln(format!"#EXTALB:%s"(m.album));
        if (m.artist)
            m3uFile.writeln(format!"#EXTART:%s"(m.artist));
        if (m.genre)
            m3uFile.writeln(format!"#EXTGENRE:%s"(m.genre));

        if (localhost)
            m3uFile.writeln(format!(LOCALHOST_GATEWAY ~ "\n")(m.hash));
        else
            m3uFile.writeln(format!(RELIABLE_GATEWAYS[$ - 1] ~ "\n")(m.hash));
    }
}

void writeXSPF(string filename, string name, Metadata[] files)
{
    auto file = new File(filename, "w");
    scope(exit) file.close();

    auto writer = xmlWriter(appender!string());
    {
        writer.openStartTag("playlist", Newline.no);
        scope(exit) writer.writeEndTag(Newline.no);
        { scope(exit) writer.closeStartTag();
            writer.writeAttr("version", "1");
            writer.writeAttr("xmlns", "http://xspf.org/ns/0/");
        }

        writer.writeTaggedText("title", encodeText(name), Newline.no, InsertIndent.no);

        {
            writer.writeStartTag("trackList", Newline.no);
            scope(exit) writer.writeEndTag(Newline.no);

            foreach(Metadata m; files)
            {
                writer.writeStartTag("track", Newline.no);
                scope(exit) writer.writeEndTag(Newline.no);

                if (m.title)
                    writer.writeTaggedText("title", encodeText(m.title), Newline.no, InsertIndent.no);
                if (m.artist)
                    writer.writeTaggedText("creator", encodeText(m.artist), Newline.no, InsertIndent.no);
                if (m.album)
                    writer.writeTaggedText("album", encodeText(m.album), Newline.no, InsertIndent.no);
                if (m.infoLink)
                    writer.writeTaggedText("info", encodeText(m.infoLink), Newline.no, InsertIndent.no);
                if (m.trackNo > 0)
                    writer.writeTaggedText("trackNum", encodeText(m.trackNo.to!string), Newline.no, InsertIndent.no);
                if (m.duration)
                    writer.writeTaggedText("duration", encodeText(m.duration.total!"msecs".to!string), Newline.no, InsertIndent.no);

                foreach(gw; RELIABLE_GATEWAYS)
                    writer.writeTaggedText("location", format(gw, m.hash), Newline.no, InsertIndent.no);

                if (localhost)
                    writer.writeTaggedText("location", format(LOCALHOST_GATEWAY, m.hash), Newline.no, InsertIndent.no);
            }
        }
    }

    file.write(`<?xml version="1.0" encoding="UTF-8"?>`);
    file.writeln(writer.output.data);
}

int main(string[] args)
{
    auto helpInformation = getopt(
        args, "localhost", &localhost);

    if (helpInformation.helpWanted)
    {
      defaultGetoptPrinter("Some information about the program.",
        helpInformation.options);
      return 0;
    }

    auto playlists = dirEntries("store/metadata/", SpanMode.breadth)
        .filter!(f => f.isFile)
        .map!(f => tuple(baseName(dirName(f.name)), f))
        .fold!((a,b){ a[b[0]] ~= b[1]; return a;})
            (DirEntry[][string].init);

    auto files = playlists.values.join.filter!(f => !f.isSymlink);
    auto filesMetadata = files.map!(f => Metadata(f)).array;

    mkdirRecurse("playlists");

    writeM3U("playlists/all.m3u", filesMetadata);
    writeXSPF("playlists/all.xspf", "all", filesMetadata);

    foreach(key; playlists.keys)
    {
        Metadata[] metadataList = playlists[key].map!(f => Metadata(f)).array;

        writeM3U(format!"playlists/%s.m3u"(key), metadataList);
        writeXSPF(format!"playlists/%s.xspf"(key), key, metadataList);
    }

    return 0;
}

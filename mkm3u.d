#!/usr/bin/env rdmd

import std.file;
import std.algorithm;
import std.path;
import std.stdio;
import std.json;
import std.range;
import std.format;

int main()
{
    auto files = dirEntries("store/metadata/", SpanMode.breadth)
        .filter!(f => f.isFile && !f.isSymlink);

    mkdirRecurse("playlists");

    auto m3uFile = new File("playlists/all.m3u", "w");
    m3uFile.writeln("#EXTM3U\n");

    foreach (string name; files)
    {
        writeln(name);
        auto json = parseJSON(readText(name));

        // get object, if array
        if (json.type == JSONType.array)
            json = json.array[0];


        m3uFile.write("#EXTINF:-1,");
        if ("Title" in json && json["Title"].type == JSONType.string && !json["Title"].str.empty)
            m3uFile.writeln(json["Title"].str);
        else if ("FileName" in json && json["FileName"].type == JSONType.string && !json["FileName"].str.empty)
            m3uFile.writeln(json["FileName"].str);
        else
            assert(0, "Can't get name!");

        if ("Album" in json && json["Album"].type == JSONType.string && !json["Album"].str.empty)
            m3uFile.writeln(format!"#EXTALB:%s"(json["Album"].str));
        if ("Artist" in json && json["Artist"].type == JSONType.string && !json["Artist"].str.empty)
            m3uFile.writeln(format!"#EXTART:%s"(json["Artist"].str));
        if ("Genre" in json && json["Genre"].type == JSONType.string && !json["Genre"].str.empty)
            m3uFile.writeln(format!"#EXTGENRE:%s"(json["Genre"].str));

        m3uFile.writeln(format!"http://localhost:8080/ipfs/%s\n"(baseName(name)));
    }
    m3uFile.close();
    return 0;
}

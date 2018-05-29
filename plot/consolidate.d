#!/usr/bin/env rdmd
import std.csv;
import std.file;
import std.stdio;
import std.range;
import std.string;
import std.typecons;
import std.exception;
import std.algorithm;

int main(string[] argv) {
    if (argv.length != 2) {
        stderr.writeln("usage: consolidate <dir_name>");
        return 1;
    }

    writeln("timestamp,washers,dryers");
    auto ents = dirEntries(argv[1], SpanMode.depth);
    foreach (fname; ents) {
        if (!isFile(fname))
            continue;

        auto file = File(fname, "r");
        auto lines = file.byLine;
        auto date = lines.take(1);

        // empty file
        if (date.empty)
            continue;

        auto ds =
          date.front
          .replace("# ", "")
          .replace(",", "");

        uint dryers  = 0;
        uint washers = 0;
        auto f = () {
            auto records = 
              lines.drop(2).join("\n").replace("\"", "'")
              .csvReader!(Tuple!(uint,string,string,string));

            foreach (record; records) {
                auto index   = record[0];
                auto type    = record[1];
                auto status  = record[2];
                auto eta     = record[3];

                if (status != "Available") {
                    if (type.canFind("Dryer"))
                        dryers++;
                    else if (type.canFind("Washer"))
                        washers++;
                }
            }
        };
        auto e = collectException(f());

        if (e) {
            stderr.writeln("skipping file: ", fname);
            stderr.writeln("\t", e);
            continue;
        }

        writefln("%s,%u,%u", ds, washers, dryers);
    }

    return 0;
}

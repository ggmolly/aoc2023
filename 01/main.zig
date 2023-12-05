const std = @import("std");

fn part_one() !void {
    var file = try std.fs.cwd().openFile("./input.txt", .{});
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var n: u64 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var digits: [2]u8 = undefined;
        for (0..line.len) |i| {
            switch (line[i]) {
                '0'...'9' => {
                    digits[0] = line[i] - '0';
                    break;
                },
                else => {},
            }
        }
        var c = line.len - 1;
        while (c >= 0) {
            switch (line[c]) {
                '0'...'9' => {
                    digits[1] = line[c] - '0';
                    break;
                },
                else => {},
            }
            c -= 1;
        }
        n += digits[0] * 10 + digits[1];
    }
    try std.fmt.format(std.io.getStdOut().writer(), "{d}\n", .{n});
}

const DIGITS: [9][]const u8 = .{
    "one", "two", "three", "four", "five", "six", "seven", "eight", "nine",
};

fn is_litteral_digit(buf: []const u8, i: usize) !u8 {
    // checks whether there's a 'one'...'nine' at offset
    // returns -1 if false, the digit as integer otherwise
    var n: u8 = 0;
    for (DIGITS) |digit| {
        n += 1;
        if (buf.len - i < digit.len) { // needle is too long
            continue;
        }
        // check if buffer starts with needle
        var found = true;
        for (0..digit.len) |j| {
            if (buf[i + j] != digit[j]) {
                found = false;
                break;
            }
        }
        if (found) {
            return n;
        }
    }
    return 0;
}

fn part_two() !void {
    var file = try std.fs.cwd().openFile("./input2.txt", .{});
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var n: u64 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var digits: [2]u8 = .{ 0, 0 };
        var c: usize = 0;
        while (c < line.len) {
            switch (line[c]) {
                'a'...'z' => {
                    const digit = try is_litteral_digit(line, c);
                    if (digit != 0) {
                        digits[0] = digit;
                        break;
                    }
                },
                '1'...'9' => {
                    digits[0] = line[c] - '0';
                    break;
                },
                else => {},
            }
            c += 1;
        }
        // same iteration but backwards
        c = line.len - 1;
        while (c >= 0) {
            switch (line[c]) {
                '1'...'9' => {
                    digits[1] = line[c] - '0';
                    break;
                },
                'a'...'z' => {
                    const digit = try is_litteral_digit(line, c);
                    if (digit != 0) {
                        digits[1] = digit;
                        break;
                    }
                },
                else => {},
            }
            c -= 1;
        }
        n += digits[0] * 10 + digits[1];
    }
    try std.fmt.format(std.io.getStdOut().writer(), "{d}\n", .{n});
}

pub fn main() !void {
    try part_one();
    try part_two();
}

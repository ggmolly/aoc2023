const std = @import("std");

const Word = enum {
    RED,
    GREEN,
    BLUE,
    GAME_END,
    UNKNOWN,
};

fn get_next_word(line: []const u8) Word {
    var i: usize = 0;
    var word_end: usize = 0;
    if (line[0] == ';') {
        return Word.GAME_END;
    }
    while (i < line.len) {
        const c = line[i];
        switch (c) {
            'a'...'z' => {
                word_end += 1;
            },
            else => {
                break;
            },
        }
        i += 1;
    }
    if (std.mem.eql(u8, line[0..word_end], "red")) {
        return Word.RED;
    } else if (std.mem.eql(u8, line[0..word_end], "green")) {
        return Word.GREEN;
    } else if (std.mem.eql(u8, line[0..word_end], "blue")) {
        return Word.BLUE;
    }
    return Word.UNKNOWN;
}

fn get_next_number(line: []const u8) std.meta.Tuple(&.{ u64, usize }) {
    var i: usize = 0;
    var number_end: usize = 0;
    while (i < line.len) {
        const c = line[i];
        switch (c) {
            '0'...'9' => {
                number_end += 1;
            },
            else => {
                break;
            },
        }
        i += 1;
    }
    const n: u64 = std.fmt.parseUnsigned(u64, line[0..number_end], 10) catch {
        return .{ 0, number_end };
    };
    return .{ n, number_end };
}

fn is_possible(red: u64, green: u64, blue: u64) bool {
    return red <= 12 and green <= 13 and blue <= 14;
}

fn parse_line(line: []const u8) bool {
    var red: u64 = 0;
    var green: u64 = 0;
    var blue: u64 = 0;

    var i: usize = 0;
    while (i < line.len) {
        const n_index = get_next_number(line[i..]);
        if (n_index[0] != 0) {
            i += n_index[1] + 1;
        }
        const word = get_next_word(line[i..]);
        // if (word != Word.UNKNOWN) {
        //     std.debug.print("[{any} x {d}] Line: {s}\n", .{ word, n_index[0], line[i..] });
        // }
        switch (word) {
            Word.RED => {
                red += n_index[0];
                i += 3;
            },
            Word.GREEN => {
                green += n_index[0];
                i += 5;
            },
            Word.BLUE => {
                blue += n_index[0];
                i += 4;
            },
            Word.GAME_END => {
                if (!is_possible(red, green, blue)) {
                    return false;
                }
                red = 0;
                green = 0;
                blue = 0;
                i += 2;
            },
            else => {
                i += 1;
            },
        }
    }

    if (!is_possible(red, green, blue)) {
        return false;
    }

    return true;
}

fn parse_line_p2(line: []const u8) std.meta.Tuple(&.{ u64, u64, u64, usize }) {
    var red: u64 = 0;
    var green: u64 = 0;
    var blue: u64 = 0;

    var i: usize = 0;
    while (i < line.len) {
        const n_index = get_next_number(line[i..]);
        if (n_index[0] != 0) {
            i += n_index[1] + 1;
        }
        const word = get_next_word(line[i..]);
        // if (word != Word.UNKNOWN) {
        //     std.debug.print("[{any} x {d}] Line: {s}\n", .{ word, n_index[0], line[i..] });
        // }
        switch (word) {
            Word.RED => {
                red += n_index[0];
                i += 3;
            },
            Word.GREEN => {
                green += n_index[0];
                i += 5;
            },
            Word.BLUE => {
                blue += n_index[0];
                i += 4;
            },
            Word.GAME_END => {
                return .{ red, green, blue, i };
            },
            else => {
                i += 1;
            },
        }
    }

    return .{ red, green, blue, i };
}

fn part_two() !void {
    var file = try std.fs.cwd().openFile("./input.txt", .{});
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var n: u128 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var offset: usize = 0;
        var min_red: u64 = 0;
        var min_green: u64 = 0;
        var min_blue: u64 = 0;
        while (offset < line.len) {
            const parsed = parse_line_p2(line[offset..]);
            offset += parsed[3] + 1;
            if (parsed[0] > min_red and parsed[0] != 0) {
                min_red = parsed[0];
            }
            if (parsed[1] > min_green and parsed[1] != 0) {
                min_green = parsed[1];
            }
            if (parsed[2] > min_blue and parsed[2] != 0) {
                min_blue = parsed[2];
            }
        }
        n += min_red * min_green * min_blue;
    }
    try std.fmt.format(std.io.getStdOut().writer(), "{d}\n", .{n});
}

fn part_one() !void {
    var file = try std.fs.cwd().openFile("./input.txt", .{});
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    const max_red = 12;
    _ = max_red;
    const max_green = 13;
    _ = max_green;
    const max_blue = 14;
    _ = max_blue;
    var sum: u64 = 0;
    var game_id: u64 = 1;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const possible = parse_line(line);
        if (possible) {
            std.debug.print("Game {d} is possible\n", .{game_id});
            sum += game_id;
        } else {
            std.debug.print("Game {d} is not possible\n", .{game_id});
        }
        game_id += 1;
    }
    try std.fmt.format(std.io.getStdOut().writer(), "{d}\n", .{sum});
}

pub fn main() !void {
    try part_one();
    try part_two();
}

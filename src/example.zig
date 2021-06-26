const std = @import("std");
const bnc = @import("bnc");

const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    var buf: [7]u8 = undefined;

    bnc.init();

    while (true) {
        try stdout.print("your guess?", .{});

        if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |user_input| {
            var guess = std.fmt.parseInt(u24, user_input[0..6], 16) catch {
                try stdout.print("Please enter a 6-digit hexadecimal number.\n", .{});
                continue;
            };
            const t = bnc.bnc(guess);
            if (t.bulls == 7) {
                try stdout.print("The digits must be all different.\n", .{});
                continue;
            }
            try stdout.print("{} bulls {} cows\n", .{ t.bulls, t.cows });
            if (t.bulls == 6) return;
            bnc.cleanup();
        }
    }
}

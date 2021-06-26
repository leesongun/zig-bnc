inline fn tobits(i: u32) u16 {
    var ret: u16 = 0;
    comptime var j = 0;
    inline while (j < 6) : (j += 1)
        ret |= @as(u16, 1) << @truncate(u4, i >> 4 * j);
    return ret;
}

inline fn eq(a: Data, b: Data) u8 {
    const cows = @bitCast(u64, Data{ .value = 0, .bits = 0xFFFF });
    const bulls = @bitCast(u64, Data{ .value = 0x111111, .bits = 0 });
    var t = @bitCast(u64, a) ^ @bitCast(u64, b);
    var u = t & t >> 1;

    return @popCount(u64, u & u >> 2 & bulls) | @popCount(u64, t & cows) << 2;
}

const Data = packed struct { value: u32, bits: u16, data: u16 = 0 };

var arr: [16 * 15 * 14 * 13 * 12 * 11]Data = undefined;
var len = arr.len;
var argmax: usize = 0;

pub fn init() void {
    var i: u32 = 0;
    var j: usize = 0;
    while (i < 0x1000000) : (i += 1) {
        const bits = tobits(i);
        if (@popCount(u32, bits) == 6) {
            arr[j] = .{ .value = i, .bits = bits };
            j += 1;
        }
    }
}

const sort = @import("std").sort;

pub fn bnc(guess: u32) struct { bulls: u3, cows: u3 } {
    var count = [_]u32{0} ** 56;
    const precomp = Data{ .value = ~guess, .bits = tobits(guess) };

    if (@popCount(u16, precomp.bits) != 6)
        return .{ .bulls = 7, .cows = 7 };

    for (arr[0..len]) |*value| {
        value.*.data = eq(precomp, value.*);
        count[value.*.data] += 1;
    }

    argmax = sort.argMax(u32, &count, {}, comptime sort.asc(u32)).?;
    const bulls = @truncate(u3, argmax);
    const cows = 6 - @truncate(u3, argmax >> 3) - bulls;

    return .{ .bulls = bulls, .cows = cows };
}

pub fn cleanup() void {
    var newlen: usize = 0;
    for (arr[0..len]) |value|
        if (value.data == argmax) {
            arr[newlen] = value;
            newlen += 1;
        };
    len = newlen;
}

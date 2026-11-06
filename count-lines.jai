#import "Basic";
#import "String";
#import "File";
#import "File_Utilities";

// what I want is for this to be, in practice, an alternative to tokei
// tokei counts lines of code understanding all kinds of different langauges,
// for the purposes of this program, lets keep it only to counting lines of code of jai

IGNORED_DIRECTORY_NAMES :: string.[
    ".build",
    ".git",
    // should we ignore the `modules` directory?
];

Fixed_Buffer :: struct {
    data: *u8;
    size: s64;
    used: s64;
    last: *u8;
}
fixed_buffer_proc :: (mode:           Allocator_Mode,
                      requested_size: s64,
                      old_size:       s64,
                      old_memory:     *void,
                      allocator_data: *void) -> *void {
    fb := cast(*Fixed_Buffer) allocator_data;
    if mode == {
        case .FREE;
            if old_memory && old_memory == fb.last {
                fb.used = fb.last - fb.data;
                fb.last = null;
            }
        case .ALLOCATE; #through;
        case .RESIZE;
            size := (requested_size + 7) & ~7;
            if mode == .RESIZE && old_memory && old_memory == fb.last {
                start := fb.last - fb.data;
                if size > fb.size - start  return null;
                fb.used = start + size;
                return old_memory;
            }
            if size > fb.size - fb.used  return null;
            result := fb.data + fb.used;
            fb.used += size;
            fb.last = result;
            if mode == .RESIZE && old_memory  memcpy(result, old_memory, min(old_size, requested_size));
            return result;
    }
    return null;
}
MEMORY_BUFFER:     [4_000_000]u8; // 4 megabytes
main :: () {
    fixed_buffer     := Fixed_Buffer.{MEMORY_BUFFER.data, MEMORY_BUFFER.count, 0, null};
    context.allocator = Allocator.{fixed_buffer_proc, *fixed_buffer};

    visit_files(".", true, null, (info:      *File_Visit_Info,
                                  user_data: *void) {
        if ends_with(info.full_name, ".jai") {
            file_contents, success := read_entire_file(info.full_name);
            defer free(file_contents);
            if success {
                cursor            := 0;
                is_inside_comment := false;
                while true {
                    next_line_break := find_index_from_left(file_contents, "\n", cursor);
                    defer {
                        if next_line_break == -1 break;
                        cursor = next_line_break + 1;
                    }
                    line: string     = ---;
                    line.data        = file_contents.data + cursor;
                    line.count       = ifx next_line_break != -1 then next_line_break - cursor else file_contents.count - cursor;

                    depth                            := 0;
                    has_code, has_comment, in_string := false;
                    index                            := 0;
                    while index < line.count {
                        character      := line[index];
                        next_character := ifx index + 1 < line.count then line[index + 1] else 0;
                        if depth > 0 {
                            has_comment = true;
                            if character == #char "/" && next_character == #char "*" { depth += 1; index += 2; continue; }
                            if character == #char "*" && next_character == #char "/" { depth -= 1; index += 2; continue; }
                        } else if in_string {
                            has_code = true;
                            if character == #char "\\" { index += 2; continue; }
                            if character == #char "\"" in_string = false;
                        } else if character == #char "/" && next_character == #char "/" {
                            has_comment = true;
                            break;
                        } else if character == #char "/" && next_character == #char "*" {
                            has_comment = true;
                            depth       = 1;
                            index      += 2;
                            continue;
                        } else if character == #char "\"" {
                            has_code  = true;
                            in_string = true;
                        } else if !is_space(character) {
                            has_code = true;
                        }
                        index += 1;
                    }

                    if has_code lines_of_code += 1;
                    else if has_comment lines_of_comments += 1;
                    else lines_of_blank += 1;
                    lines += 1;
                }
                assert(lines_of_code + lines_of_comments + lines_of_blank == lines);
            } else {
                line_count_report();
                exit(-1);
            }
        }
    });
    line_count_report();
}
lines:             u64;
lines_of_code:     u64;
lines_of_blank:    u64;
lines_of_comments: u64;
line_count_report :: () {
    width := 1;
    n     := lines;
    while n >= 10 { n /= 10; width += 1; }

    print(#string END
Lines of code:     %
Lines of comments: %
Lines of blank:    %
----------------------
Lines:             %
END,
        FormatInt.{value = lines_of_code,     minimum_digits = width, padding = #char " "},
        FormatInt.{value = lines_of_comments, minimum_digits = width, padding = #char " "},
        FormatInt.{value = lines_of_blank,    minimum_digits = width, padding = #char " "},
        FormatInt.{value = lines,             minimum_digits = width, padding = #char " "});
}

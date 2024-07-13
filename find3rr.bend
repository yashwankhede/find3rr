import std.process
import std.fs
import std.os
import std.threading

fn show_help() {
    println("Usage: find3rr.bnd [option] [value]")
    println("Options:")
    println("  -f filename  Search for a file with the given name.")
    println("  -d directory Search for a directory with the given name.")
    println("  -t text      Search for a text string within files.")
    println("  -h           Display this help message.")
}

fn check_requirements() -> bool {
    if !os.is_executable("find") {
        println("find command is required but not found. Please install it.")
        return false
    }
    
    if !os.is_executable("grep") {
        println("grep command is required but not found. Please install it.")
        return false
    }
    
    if !os.is_executable("tree") {
        println("tree command is required but not found. Install it with: sudo apt-get install tree (Debian-based) or sudo yum install tree (RHEL-based).")
        return false
    }
    
    return true
}

fn search_file(filename: str) {
    println("Searching for file: " + filename)
    let results = process.exec("find . -type f -name " + filename)
    for result in results.output.split("\n") {
        if result != "" {
            threading.spawn(move || {
                process.exec("tree -L 1 " + fs.dirname(result))
            })
        }
    }
}

fn search_directory(dirname: str) {
    println("Searching for directory: " + dirname)
    let results = process.exec("find . -type d -name " + dirname)
    for result in results.output.split("\n") {
        if result != "" {
            threading.spawn(move || {
                process.exec("tree -L 1 " + result)
            })
        }
    }
}

fn search_text(text: str) {
    println("Searching for text: " + text)
    let results = process.exec("grep -rnl . -e " + text)
    for result in results.output.split("\n") {
        if result != "" {
            threading.spawn(move || {
                process.exec("tree -L 1 " + fs.dirname(result))
            })
        }
    }
}

fn main() {
    if !check_requirements() {
        return
    }

    let args = os.args()
    if args.len() < 2 {
        show_help()
        return
    }

    let option = args[1]
    let value = if args.len() > 2 { args[2] } else { "" }

    match option {
        "-f" => search_file(value),
        "-d" => search_directory(value),
        "-t" => search_text(value),
        "-h" => show_help(),
        _ => {
            println("Invalid option: " + option)
            show_help()
        }
    }
}

main()

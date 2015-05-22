mod networking;

//use std::vec::Vec;

fn main() {
    let output_ = networking::discover_hosts();
    if output_.is_err()
    {
        println!("Broadcast threw an error.");
        return
    }
    let output = output_.unwrap();
    println!("Length is: {}", output.len());
    for i in output
    {
        let (addr, name) = i;
        println!("{}; {}", addr, name);
    }
}

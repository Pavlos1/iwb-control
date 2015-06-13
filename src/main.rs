#[macro_use]
extern crate qmlrs;
extern crate libc;
mod networking;
mod gui;

fn main() {
    gui::create_main_window();
    /*
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
        let (addr, name): (String, String) = i;
        println!("{}; {}", addr, name);
        match networking::send_command(addr, "PWR?".to_string(), None)
        {
            Ok(v) => println!("{}", v),
            Err(e) => println!("{}", e),
        };
    }
    */
}

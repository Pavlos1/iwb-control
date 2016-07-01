use networking;
use qmlrs;

use std::vec::Vec;
use std::io::prelude::*;
use std::net::TcpStream;

struct Networking { stream: Option<TcpStream>, password: Option<String> }
impl Networking
{
    fn discover_hosts(&self) -> String
    {
        match networking::discover_hosts()
        {
            Ok(v) => stringify_vector(v),
            Err(e) => stringify_vector(err_vec(e)),
        }
    }
    
    fn connect_tcp(&mut self, display: String) -> String
    {
        let mut addr = String::new();
        let mut addr_start = false;
        let mut at_reached = false;
        for i in display.chars()
        {
            if addr_start { addr.push(i); }
            else if i == '@' { at_reached = true; }
            else if at_reached && (i == ' ') { addr_start = true; }
        }

        let stream_ = networking::connect_tcp(addr, self.password.clone());
        if stream_.is_ok()
        {
            self.stream = Some(stream_.unwrap());
            "OK".to_string()
        }
        else
        {
            match stream_
            {
                Ok(_) => unreachable!(),
                Err(e) => e.to_string(),
            }
        }
    }
    
    fn close_connection(&mut self)
    {
        self.stream = None;
    }
    
    fn send_command(&mut self, command: String) -> String
    {
        let buf: &mut [u8] = &mut [0; 1024];
        let mut stream = match self.stream
        {
            Some(ref v) => v,
            None => return "Error: no connection open".to_string(),
        };
        let _ = stream.write(command.as_bytes());
        let _ = stream.write("\r".as_bytes());
        let _ = stream.read(&mut (*buf));
        
        String::from_utf8_lossy(buf).replace("\r:", "")
    }
    
    fn set_password(&mut self, password: String)
    {
        if password != "".to_string()
        {
            self.password = Some(password);
        } else {
            self.password = None;
        }
    }
}

Q_OBJECT! { Networking:
    slot fn discover_hosts();
    slot fn connect_tcp(String);
    slot fn close_connection();
    slot fn send_command(String);
    slot fn set_password(String);
}

pub fn stringify_vector(vector: Vec<(String, String)>) -> String
{
    let mut ret = String::new();
    ret.push('[');
    for i in vector.clone()
    {
        let (addr, name) = i;
        ret.push('"');
        ret = ret + &name[..];
        ret = ret + " @ ";
        ret = ret + &addr[..];
        ret.push('"');
        ret = ret + ", ";
    }
    if vector.len() != 0
    {
        let _ = ret.pop();
        let _ = ret.pop();
    }
    ret.push(']');
    ret
}

pub fn err_vec(e: &'static str) -> Vec<(String, String)>
{
    let mut ret = Vec::<(String, String)>::new();
    ret.push(("Error".to_string(), e.to_string()));
    
    ret
}

pub fn create_main_window()
{
    let mut engine = qmlrs::Engine::new();
    engine.set_property("Networking", Networking { stream: None, password: None });
    engine.load_local_file("main_window.qml");
    
    engine.exec();
}

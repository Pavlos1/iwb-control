use networking;
use qmlrs;

use std::vec::Vec;
use std::io::prelude::*;

struct DiscoverHosts;
impl DiscoverHosts
{
    fn discover_hosts(&self) -> String 
    {
        match networking::discover_hosts()
        {
            Ok(v) => stringify_vector(v),
            Err(e) => stringify_vector(err_vec(e)),
        }
    }
}

Q_OBJECT! { DiscoverHosts:
    slot fn discover_hosts();
}

pub fn stringify_vector(vector: Vec<(String, String)>) -> String
{
    let mut ret = String::new();
    ret.push('[');
    for i in vector
    {
        let (addr, name) = i;
        ret.push('"');
        ret = ret + &name[..];
        ret = ret + " @ ";
        ret = ret + &addr[..];
        ret.push('"');
        ret = ret + ", ";
    }
    let _ = ret.pop();
    let _ = ret.pop();
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
    engine.set_property("DiscoverHosts", DiscoverHosts);
    engine.load_local_file("main_window.qml");
    
    engine.exec();
}

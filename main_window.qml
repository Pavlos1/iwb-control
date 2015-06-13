import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0

ApplicationWindow
{
    visible: true
    title: "ESC/VP.net client"
    
    property int margin: 11
    width: mainLayout.implicitWidth + 2 * margin
    height: mainLayout.implicitHeight + 2 * margin
    minimumWidth: mainLayout.Layout.minimumWidth + 2 * margin
    minimumHeight: mainLayout.Layout.minimumHeight + 2 * margin
    
    RowLayout
    {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: margin
        
        ColumnLayout
        {
            id: selectionLayout
            //anchors.fill: parent
            anchors.margins: margin
        
            Button
            {
                width: 150
                height: 75
                text: "Refresh hosts list"
                onClicked: refresh_hosts_and_show();
            }
        
            ColumnLayout
            {
                id: hostsLayout
            }
        }
        
        ColumnLayout
        {
            id: connectionLayout
            //anchors.fill: parent
            anchors.margins: margin
            
            Text
            {
                id: statusText
                text: "No connections open";
            }
            
            RowLayout
            {
                id: powerLayout
                //anchors.fill: parent
                
                Text
                {
                    id: powerText
                    text: "Power: "
                    visible: false
                }
                
                Switch
                {
                    id: powerSwitch
                    checked: false
                    visible: false
                }
            }
        }
    }
    
    Timer
    {
        id: updateTimer
        interval: 500
        running: false
        repeat: true
        onTriggered: updateStates()
    }
    
    property variant hostsList: [];
    
    function openConnection(display)
    {
        var status = Networking.connect_tcp(display);
        
        if (status === "OK")
        {
            powerText.visible = true;
            powerSwitch.visible = true;
            updateTimer.running = true;
        } else {
            powerText.visible = false;
            powerSwitch.visible = false;
            updateTimer.running = false;
        }
        
        statusText.text = status;
    }
    
    function updateStates()
    {
        var power = Networking.send_command("PWR?");
        var powIndex = power.search("PWR=");
        if (powIndex === -1)
        {
            powerText.visible = false;
            powerSwitch.visible = false;
            updateTimer.running = false;
            statusText.text = "Connection closed by host. Try reconnecting.";
        } else {
            if (power[powIndex+4] + power[powIndex+5] == "01")
            {
                powerSwitch.checked = true;
            } else {
                powerSwitch.checked = false;
            }
        }
    }
    
    function formatDisplay(display)
    {
        var position = 0;
        var output = "";
        
        output += "<b>";
        while (display[position] != ' ')
        {
            output += display[position];
            position++;
        }
        output += "</b>"
        output += "<i>"
        while (position < display.length)
        {
            output += display[position];
            position++;
        }
        output += "</i>"
        
        return output;
    }
    
    function refresh_hosts_and_show()
    {
        for (var i=0; i<hostsList.length; i++)
        {
            hostsList[i].destroy();
        }
        hostsList = [];
        
        var hosts_str = Networking.discover_hosts();
        var hosts = JSON.parse(hosts_str);
        for (var i=0; i<hosts.length; i++)
        {
            hostsList.push(Qt.createQmlObject('import QtQuick 2.2; import QtQuick.Controls 1.2; Button { width: 150; height: 75; text: "'+formatDisplay(hosts[i])+'"; onClicked: openConnection("'+hosts[i]+'"); }', hostsLayout, "foo"));
        }
    }
}
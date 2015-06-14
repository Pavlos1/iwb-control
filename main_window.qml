import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0

ApplicationWindow
{
    visible: true
    title: "ESC/VP.net client"
    
    property int margin: 11
    width: mainLayout.implicitWidth + 2 * margin + 50
    height: mainLayout.implicitHeight + 2 * margin + 75
    minimumWidth: mainLayout.Layout.minimumWidth + 2 * margin + 50
    minimumHeight: mainLayout.Layout.minimumHeight + 2 * margin + 75
    
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
            anchors.top: mainLayout.top
        
            Button
            {
                width: 150
                height: 75
                text: "Refresh hosts list"
                onClicked: refresh_hosts_and_show();
            }
        
            ColumnLayout
            {
                anchors.margins: margin
                id: hostsLayout
                
                Button
                {
                    //anchors.margins: margin
                    id: spacerButton
                    width: 150
                    height: 75
                    opacity: 0
                    visible: true
                    
                    Component.onCompleted: hostsList.push(spacerButton)
                }
            }
            
            RowLayout
            {
                id: directConnectLayout
                anchors.top: hostsLayout.bottom
                
                TextField
                {
                    anchors.bottom: directConnectLayout.bottom
                    Layout.fillWidth: false
                    focus: true
                    id: directConnectInput
                    onAccepted: openConnection(formatIP(directConnectInput.text))
                }
            
                Button
                {
                    anchors.bottom: directConnectLayout.bottom
                    id: directConnectButton
                    text: "Direct connect"
                    onClicked: openConnection(formatIP(directConnectInput.text))
                }
            }
        }
        
        ColumnLayout
        {
            id: connectionLayout
            anchors.top: mainLayout.top
            anchors.bottom: mainLayout.bottom
            anchors.right: mainLayout.right
            anchors.margins: margin
            
            Text
            {
                anchors.margins: margin
                id: statusText
                text: "<b>No connections open</b>";
            }
            
            Text
            {
                anchors.margins: margin
                id: displayText
                text: ""
                visible: false
            }
            
            RowLayout
            {
                anchors.margins: margin
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
                    onClicked: { if (!powerSwitch.checked) { Networking.send_command("PWR OFF"); } else { Networking.send_command("PWR ON"); } }
                }
                
                Text
                {
                    anchors.margins: margin
                    id: powerLevel
                    visible: false
                }
            }
            
            RowLayout
            {
                anchors.margins: margin
                id: hreverseLayout
                //anchors.fill: parent
                
                Text
                {
                    id: hreverseText
                    text: "HREVERSE: "
                    visible: false
                }
                
                Switch
                {
                    id: hreverseSwitch
                    checked: false
                    visible: false
                    onClicked: { if (!hreverseSwitch.checked) { Networking.send_command("HREVERSE OFF"); } else { Networking.send_command("HREVERSE ON"); } }
                }
            }
                
            RowLayout
            {
                anchors.margins: margin
                id: vreverseLayout
                //anchors.fill: parent
                
                Text
                {
                    id: vreverseText
                    text: "VREVERSE: "
                    visible: false
                }
                
                Switch
                {
                    id: vreverseSwitch
                    checked: false
                    visible: false
                    onClicked: { if (!vreverseSwitch.checked) { Networking.send_command("VREVERSE OFF"); } else { Networking.send_command("VREVERSE ON"); } }
                }
            }
            
            Text
            {
                anchors.margins: margin
                anchors.bottom: passwordField.top
                text: "Password (optional):"
                visible: true
            }
            
            TextField
            {
                Layout.fillWidth: false
                anchors.margins: margin
                anchors.bottom: reconnectButton.top
                id: passwordField
                visible: true
                width: 100
            }
            
            Button
            {
                anchors.margins: margin
                anchors.bottom: closeButton.top
                id: reconnectButton
                text: "Reconnect"
                visible: true
                opacity: 0
                onClicked: { closeConnection(); openConnection(cachedDisplay); }
            }
            
            Button
            {
                anchors.margins: margin
                anchors.bottom: connectionLayout.bottom
                id: closeButton
                text: "Close"
                visible: false
                onClicked: { closeConnection(); reconnectButton.visible = true; closeButton.visible = false; }
            }
        }
    }
    
    Timer
    {
        id: updateTimer
        interval: 500
        running: false
        repeat: false
        onTriggered: updateStates()
    }
    
    property variant hostsList: [];
    property string cachedDisplay: "";
    
    function closeConnection()
    {
        powerText.visible = false;
        powerSwitch.visible = false;
        hreverseText.visible = false;
        hreverseSwitch.visible = false;
        vreverseText.visible = false;
        vreverseSwitch.visible = false;
        powerLevel.visible = false;

        displayText.visible = false;
        updateTimer.running = false;
        statusText.text = "<b>Connection closed</b>";
        Networking.close_connection();
    }
    
    function openConnection(display)
    {
        reconnectButton.opacity = 1;
        Networking.set_password(passwordField.text);
        var status = Networking.connect_tcp(display);
        cachedDisplay = display;
        
        if (status === "OK")
        {
            powerText.visible = true;
            powerSwitch.visible = true;
            displayText.visible = true;
            hreverseText.visible = false;
            hreverseSwitch.visible = false;
            vreverseText.visible = false;
            vreverseSwitch.visible = false;
            powerLevel.visible = true;
            
            reconnectButton.visible = true;
            closeButton.visible = true;
            displayText.text = formatDisplay(display);
            updateTimer.running = true;
        } else {
            closeConnection();
            statusText.text = "<b>Connection failed.</b>";
            reconnectButton.visible = true;
            closeButton.visible = false;
        }
        
        statusText.text = "<b>"+status+"</b>";
    }
    
    function updateStates()
    {
        var power = getState("PWR");
        if (power == "ERR")
        {
            closeConnection();
            statusText.text = "<b>Connection closed by host. Try reconnecting.</b>";
            reconnectButton.visible = true;
            closeButton.visible = false;
        } else {
            powerLevel.text = "("+power+")";
            if (power == "01")
            {
                powerSwitch.checked = true;
                
                hreverseText.visible = true;
                hreverseSwitch.visible = true;
                vreverseText.visible = true;
                vreverseSwitch.visible = true;
                
                var hreverse = getState("HREVERSE");
                if (hreverse == "ERR")
                {
                    closeConnection();
                    statusText.text = "<b>Connection closed by host. Try reconnecting.</b>";
                    reconnectButton.visible = true;
                    closeButton.visible = false;
                } else {
                    if (hreverse == "ON") { hreverseSwitch.checked = true; }
                    else { hreverseSwitch.checked = false; }
                    
                    var vreverse = getState("VREVERSE");
                    if (vreverse == "ERR")
                    {
                        closeConnection();
                        statusText.text = "<b>Connection closed by host. Try reconnecting.</b>";
                        reconnectButton.visible = true;
                        closeButton.visible = false;
                    } else {
                        if (vreverse == "ON") { vreverseSwitch.checked = true; }
                        else { vreverseSwitch.checked = false; }
                        updateTimer.running = true;
                    }
                }
            } else {
                if (power == "02") { powerSwitch.checked = true; } else { powerSwitch.checked = false; }
                
                hreverseText.visible = false;
                hreverseSwitch.visible = false;
                vreverseText.visible = false;
                vreverseSwitch.visible = false;
                
                updateTimer.running = true;
            }
        }
        
        var power = Networking.send_command("PWR?");
        var powIndex = power.search("PWR=");
        if (powIndex === -1)
        {
            closeConnection();
            statusText.text = "<b>Connection closed by host. Try reconnecting.</b>";
            reconnectButton.visible = true;
            closeButton.visible = false;
        } else {
            if (power[powIndex+4] + power[powIndex+5] == "01")
            {
                powerSwitch.checked = true;
            } else {
                powerSwitch.checked = false;
            }
        }
    }
    
    function getState(state)
    {
        var output = Networking.send_command(state+"?");
        var outIndex = output.search(state+"=");
        if (outIndex === -1)
        {
            return "ERR";
        } else {
            return output[outIndex + state.length + 1] + output[outIndex + state.length + 2]
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
    
    function formatIP(address)
    {
        if (address.search(":") == -1)
        {
            address = address+":3629";
        }
        return "Unknown @ "+address;
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
        hostsList.push(Qt.createQmlObject('import QtQuick 2.2; import QtQuick.Controls 1.2; Button { width: 150; height: 75; opacity: 0; visible: true; }', hostsLayout, "foo"))
    }
}
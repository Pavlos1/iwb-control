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
    
    ColumnLayout
    {
        id: mainLayout
        anchors.fill: parent
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
    
    property variant hostsList: [];
    
    function refresh_hosts_and_show()
    {
        for (var i=0; i<hostsList.length; i++)
        {
            hostsList[i].destroy();
        }
        hostsList = [];
        
        var hosts_str = DiscoverHosts.discover_hosts();
        var hosts = JSON.parse(hosts_str);
        for (var i=0; i<hosts.length; i++)
        {
            hostsList.push(Qt.createQmlObject('import QtQuick 2.2; import QtQuick.Controls 1.2; Button { width: 150; height: 75; text: "'+hosts[i]+'"; }', hostsLayout, "foo"));
        }
    }
}

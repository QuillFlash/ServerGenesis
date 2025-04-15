package com.theaestheticfur.ServerGenesis_GUI.ui;
import com.theaestheticfur.ServerGenesis_GUI.ui_logic.*;
import javax.swing.*;
public class MainPanel
{
    private JCheckBox sshCheckBox;
    private JCheckBox sftpCheckBox;
    private JTextField sftpUsernameTextField;
    private JTextField sshPortNumberTextField;
    private JCheckBox webServerCheckBox;
    private JComboBox<String> webServerTypeComboBox;
    private JComboBox<String> dbTypeComboBox;
    private JCheckBox emailServerCheckBox;
    private JButton startBackendScriptButton;
    private JPanel mainJPanel;
    private JCheckBox dbCheckBox;
    private JTextField webServerPortNumberTextField;

    public MainPanel()
    {
        JComboBox<String> wsHelper = webServerTypeComboBox;
        JComboBox<String> dbHelper = dbTypeComboBox;
        if (wsHelper != null && dbHelper != null)
        {
            webServerTypeComboBox.removeAllItems();
            webServerTypeComboBox.addItem("Apache");
            webServerTypeComboBox.addItem("Nginx");
            webServerTypeComboBox.addItem("OpenResty");
            webServerTypeComboBox.setRenderer(new PlaceholderRenderer("Please choose..."));
            webServerTypeComboBox.setSelectedIndex(-1);
            dbTypeComboBox.removeAllItems();
            dbTypeComboBox.addItem("MongoDB");
            dbTypeComboBox.addItem("MySQL");
            dbTypeComboBox.addItem("Oracle SQL");
            dbTypeComboBox.addItem("PostgreSQL");
            dbTypeComboBox.setRenderer(new PlaceholderRenderer("Please choose..."));
            dbTypeComboBox.setSelectedIndex(-1);
        }
    }

    public JPanel getMainJPanel()
    {
        return mainJPanel;
    }

    public JCheckBox getSshCheckBox()
    {
        return sshCheckBox;
    }

    public JCheckBox getSftpCheckBox()
    {
        return sftpCheckBox;
    }

    public JTextField getSftpUsernameTextField()
    {
        return sftpUsernameTextField;
    }

    public JTextField getSshPortNumberTextField()
    {
        return sshPortNumberTextField;
    }

    public JCheckBox getWebServerCheckBox()
    {
        return webServerCheckBox;
    }

    public JTextField getWebServerPortNumberTextField()
    {
        return webServerPortNumberTextField;
    }

    public JComboBox<String> getWebServerTypeComboBox()
    {
        return webServerTypeComboBox;
    }

    public JCheckBox getDbCheckBox()
    {
        return dbCheckBox;
    }

    public JComboBox<String> getDbTypeComboBox()
    {
        return dbTypeComboBox;
    }

}

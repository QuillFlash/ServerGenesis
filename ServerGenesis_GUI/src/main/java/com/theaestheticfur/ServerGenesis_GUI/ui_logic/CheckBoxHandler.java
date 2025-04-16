package com.theaestheticfur.ServerGenesis_GUI.ui_logic;
import com.theaestheticfur.ServerGenesis_GUI.ui.MainPanel;

public class CheckBoxHandler
{
    public void checkBoxLogic(MainPanel mainPanel)
    {
        mainPanel.getSshCheckBox().addItemListener(e ->
                    mainPanel.getSshPortNumberTextField()
                             .setEnabled(mainPanel.getSshCheckBox().isSelected()));
            mainPanel.getSftpCheckBox().addItemListener(e ->
                    mainPanel.getSftpUsernameTextField()
                             .setEnabled(mainPanel.getSftpCheckBox().isSelected()));
            mainPanel.getWebServerCheckBox().addItemListener(e ->
                    mainPanel.getWebServerTypeComboBox()
                             .setEnabled(mainPanel.getWebServerCheckBox().isSelected()));
            mainPanel.getWebServerCheckBox().addItemListener(e ->
                    mainPanel.getWebServerPortNumberTextField()
                             .setEnabled(mainPanel.getWebServerCheckBox().isSelected()));
            mainPanel.getDbCheckBox().addItemListener(e ->
                    mainPanel.getDbTypeComboBox()
                             .setEnabled(mainPanel.getDbCheckBox().isSelected()));
    }
}

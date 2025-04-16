package com.theaestheticfur.ServerGenesis_GUI;
import com.formdev.flatlaf.FlatDarkLaf;
import com.theaestheticfur.ServerGenesis_GUI.ui.MainPanel;
import com.theaestheticfur.ServerGenesis_GUI.ui_logic.CheckBoxHandler;
import javax.swing.*;
import java.awt.*;

public class Main
{
    public static void main(String[] args)
    {
        try
        {
            UIManager.setLookAndFeel(new FlatDarkLaf());
        }
        catch (Exception e)
        {
            System.err.println("Failed to initialise LaF: " + e.getMessage());
        }
        SwingUtilities.invokeLater(() ->
        {
            JFrame frame = new JFrame("ServerGenesis");
            MainPanel mainPanel = new MainPanel();
            /* Gemini 2.5 Pro helped me set up the correct content pane
            to display the elements of the JPanel where the buttons,
            textboxes and dropdown menus live */
            frame.setContentPane(mainPanel.getMainJPanel());
            frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
            frame.setPreferredSize(new Dimension(1024, 768));
            frame.pack();
            frame.setLocationRelativeTo(null);
            frame.setVisible(true);
            mainPanel.getSshPortNumberTextField().setEnabled(false);
            mainPanel.getSftpUsernameTextField().setEnabled(false);
            mainPanel.getWebServerPortNumberTextField().setEnabled(false);
            mainPanel.getWebServerTypeComboBox().setEnabled(false);
            mainPanel.getDbTypeComboBox().setEnabled(false);
            CheckBoxHandler checkBoxHandler = new CheckBoxHandler();
            checkBoxHandler.checkBoxLogic(mainPanel);
        });
    }
}
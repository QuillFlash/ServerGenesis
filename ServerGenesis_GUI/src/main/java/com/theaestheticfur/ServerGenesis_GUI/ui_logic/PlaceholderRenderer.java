package com.theaestheticfur.ServerGenesis_GUI.ui_logic;
import javax.swing.*;
import java.awt.*;

// Gemini 2.5 Pro suggested the getListCellRendererComponent() override

public class PlaceholderRenderer extends DefaultListCellRenderer
{
    private final String placeholder;

    public PlaceholderRenderer(String placeholder) { this.placeholder = placeholder; }

    @Override
    public Component getListCellRendererComponent(JList<?> list, Object value, int index, boolean isSelected, boolean cellHasFocus)
    {
        super.getListCellRendererComponent(list, value, index, isSelected, cellHasFocus);
        if (value == null && index == -1) setText(placeholder);
        else setForeground(list.getForeground());
        return this;
    }
}

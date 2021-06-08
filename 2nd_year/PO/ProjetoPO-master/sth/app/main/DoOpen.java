package sth.app.main;

import java.io.FileNotFoundException;
import java.io.IOException;

import pt.tecnico.po.ui.Command;
import pt.tecnico.po.ui.DialogException;
import pt.tecnico.po.ui.Input;
import sth.app.exception.NoSuchFileException;
import sth.core.SchoolManager;
import sth.core.exception.ImportFileException;


//FIXME import other classes if needed

/**
 * 4.1.1. Open existing document.
 */
public class DoOpen extends Command<SchoolManager> {

    Input<String> _fileName;

    /**
     * @param receiver
     */
    public DoOpen(SchoolManager receiver) {
        super(Label.OPEN, receiver);
        _fileName = _form.addStringInput(Message.openFile());
    }

    /**
     * @see pt.tecnico.po.ui.Command#execute()
     */
    @Override
    public final void execute() throws DialogException {
        try {
            _receiver.importFile(_fileName.value());
        } catch (ImportFileException bde) {
            throw new NoSuchFileException(_fileName.value());
        }
    }

}

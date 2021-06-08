package sth.app.teaching;

import pt.tecnico.po.ui.DialogException;
import pt.tecnico.po.ui.Input;
import sth.app.exception.NoSuchDisciplineException;
import sth.app.exception.NoSuchProjectException;
import sth.core.SchoolManager;

import sth.core.exception.NoSuchProjectIdException;
import sth.core.exception.NoSuchDisciplineIdException;

/**
 * 4.4.2. Close project.
 */
public class DoCloseProject extends sth.app.common.ProjectCommand {

    /**
     * @param receiver
     */
    public DoCloseProject(SchoolManager receiver) {
        super(Label.CLOSE_PROJECT, receiver);
    }

    /**
     * @see sth.app.common.ProjectCommand#myExecute()
     */
    @Override
    public final void myExecute() throws DialogException/*, NoSuchDisciplineIdException, NoSuchProjectIdException*/ {
        try{
            _receiver.closeProject(_discipline.value(), _project.value());
        } catch (NoSuchDisciplineIdException e){
            throw new NoSuchDisciplineException(e.getId());
        } catch (NoSuchProjectIdException e){
            throw new NoSuchProjectException(_discipline.value(), e.getId());
        }
    }

}

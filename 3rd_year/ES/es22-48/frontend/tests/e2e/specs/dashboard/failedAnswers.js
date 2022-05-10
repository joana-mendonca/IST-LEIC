describe('Student Walkthrough', () => {
    beforeEach(() => {
      cy.deleteFailedAnswers();
      cy.deleteQuestionsAndAnswers();
      //create quiz
      cy.demoTeacherLogin();
      cy.createQuestion(
        'Question Title',
        'Question',
        'Option',
        'Option',
        'Option',
        'Correct'
      );
      cy.createQuestion(
        'Question Title2',
        'Question',
        'Option',
        'Option',
        'Option',
        'Correct'
      );
      cy.createQuizzWith2Questions(
        'Quiz Title',
        'Question Title',
        'Question Title2'
      );
      cy.contains('Logout').click();
    });

    afterEach(() => {
      cy.deleteFailedAnswers();
      cy.deleteQuestionsAndAnswers();
    })

  
    it('student gets, updates and deletes failed answers', () => {
      cy.intercept('GET', '/students/dashboards/executions/*').as('getUserDashboard');
      cy.intercept('GET', '**/students/dashboards/*/failedAnswers').as('getFailedAnswers');
      cy.intercept('GET', '/questions/*/statement').as('getStatementQuestion');
      cy.intercept('DELETE', '/students/dashboards/*/failedAnswers/*').as('deleteFailedAnswer');
      cy.demoStudentLogin();
      cy.solveQuizz('Quiz Title', 0);

      cy.get('[data-cy="dashboardMenuButton"]').click();
      cy.wait('@getUserDashboard');
      cy.get('[data-cy="failedAnswersMenuButton"]').click();
      cy.wait('@getFailedAnswers');

      cy.get('[data-cy="refreshButton"]').click();
      // must wait for a second GET request: first was from opening the failed answers, second was from refreshing
      cy.wait('@getFailedAnswers');

      // open first failed answer's StudentViewDialog then close it
      cy.get('[data-cy="failedAnswersTable"] table > tbody > tr:first')
        .within(() => {
          cy.get('[data-cy="showStudentViewDialogButton"]').click();
        });
      cy.wait('@getStatementQuestion');
      cy.get('[data-cy="closeButton"]').click();

      // attempt to delete first (new) failed answer, then close error message.
      cy.get('[data-cy="failedAnswersTable"] table > tbody > tr:first')
        .within(() => {
          cy.get('[data-cy="deleteFailedAnswerButton"]').click();
      });
      cy.wait('@deleteFailedAnswer');
      cy.closeErrorMessage();

      // attempt to delete again, now with failed answer as old
      cy.setFailedAnswersAsOld();
      cy.get('[data-cy="failedAnswersTable"] table > tbody > tr:first')
        .within(() => {
          cy.get('[data-cy="deleteFailedAnswerButton"]').click();
      });
      cy.wait('@deleteFailedAnswer');
      cy.contains('Logout').click();

      Cypress.on('uncaught:exception', (err, runnable) => {
        // returning false here prevents Cypress from
        // failing the test
        return false;
      });
    });
  });

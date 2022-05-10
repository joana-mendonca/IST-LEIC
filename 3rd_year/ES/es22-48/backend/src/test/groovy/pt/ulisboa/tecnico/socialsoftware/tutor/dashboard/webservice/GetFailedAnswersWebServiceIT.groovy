package pt.ulisboa.tecnico.socialsoftware.tutor.dashboard.webservice

import groovyx.net.http.HttpResponseException
import groovyx.net.http.RESTClient
import org.apache.http.HttpStatus
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.web.server.LocalServerPort

import pt.ulisboa.tecnico.socialsoftware.tutor.auth.domain.AuthUser
import pt.ulisboa.tecnico.socialsoftware.tutor.dashboard.domain.Dashboard
import pt.ulisboa.tecnico.socialsoftware.tutor.dashboard.service.FailedAnswersSpockTest
import pt.ulisboa.tecnico.socialsoftware.tutor.user.domain.Student
import pt.ulisboa.tecnico.socialsoftware.tutor.user.domain.Teacher


import pt.ulisboa.tecnico.socialsoftware.tutor.execution.repository.CourseExecutionRepository
import pt.ulisboa.tecnico.socialsoftware.tutor.execution.domain.CourseExecution

import java.time.LocalDateTime

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class GetFailedAnswersWebServiceIT extends FailedAnswersSpockTest {
    @LocalServerPort
    private int port

    def response
    def quiz
    def quizQuestion

    def setup() {
        given:
        restClient = new RESTClient("http://localhost:" + port)
        and:
        createExternalCourseAndExecution()
        and:
        student = new Student(USER_1_NAME, USER_1_EMAIL, USER_1_EMAIL, false, AuthUser.Type.EXTERNAL)
        student.authUser.setPassword(passwordEncoder.encode(USER_1_PASSWORD))
        student.addCourse(externalCourseExecution)
        userRepository.save(student)
        and:
        dashboard = new Dashboard(externalCourseExecution, student)
        dashboardRepository.save(dashboard)

        and:
        quiz = createQuiz(1)
        quizQuestion = createQuestion(1, quiz)
    }

    def cleanup() {
        userRepository.deleteAll()
        courseRepository.deleteAll()
        quizRepository.deleteAll()
        questionRepository.deleteAll()
    }

    def "student gets failed answers"() {
        given: 'a student with a failed answer'
        createdUserLogin(USER_1_EMAIL, USER_1_PASSWORD) 
        def questionAnswer = answerQuiz(true, false, true, quizQuestion, quiz)

        def failedAnswer = createFailedAnswer(questionAnswer, LocalDateTime.now())
        def failedAnswerDto = failedAnswer.toDto()

        when: "the web service is invoked with the id of this student's dashboard"
        response = restClient.get(
            path: '/students/dashboards/' + dashboard.getId() + '/failedAnswers',
            requestContentType: 'application/json'
        )

        then: "the request returns 200"
        response.status == 200
        and: "has the failed answer"
        response.data != null
        response.data.size() == 1
        response.data.get(0).id == failedAnswerDto.getId()
        response.data.get(0).questionAnswerDto.question.id == failedAnswerDto.getQuestionAnswerDto().getQuestion().getId()

        cleanup:
        failedAnswerRepository.deleteAll()
    }

    def "teacher can't get student's failed answers"() {
        given: 'a teacher logged in'
        def teacher = new Teacher(USER_2_NAME, USER_2_EMAIL, USER_2_EMAIL, false, AuthUser.Type.EXTERNAL)
        teacher.authUser.setPassword(passwordEncoder.encode(USER_2_PASSWORD))
        teacher.addCourse(externalCourseExecution)
        userRepository.save(teacher)

        when: "the web service is invoked with the id of the student's dashboard"
        response = restClient.get(
            path: '/students/dashboards/' + dashboard.getId() + '/failedAnswers',
            requestContentType: 'application/json'
        )

        then: "the request returns 403"
        def error = thrown(HttpResponseException)
        error.response.status == HttpStatus.SC_FORBIDDEN

        cleanup:
        userRepository.deleteById(teacher.getId())
    }

    def "student can't get another student's failed answers"() {
        given: 'a student logged in'
        createdUserLogin(USER_1_EMAIL, USER_1_PASSWORD)

        and: 'another student with a dashboard'
        def student2 = new Student(USER_2_NAME, USER_2_EMAIL, USER_2_EMAIL, false, AuthUser.Type.EXTERNAL)
        student2.authUser.setPassword(passwordEncoder.encode(USER_2_PASSWORD))
        student2.addCourse(externalCourseExecution)
        userRepository.save(student2)
        and:
        def dashboard2 = new Dashboard(externalCourseExecution, student2)
        dashboardRepository.save(dashboard2)
        
        when: "the web service is invoked with the id of the second student's dashboard"
        response = restClient.get(
            path: '/students/dashboards/' + dashboard2.getId() + '/failedAnswers',
            requestContentType: 'application/json'
        )

        then: "the request returns 403"
        def error = thrown(HttpResponseException)
        error.response.status == HttpStatus.SC_FORBIDDEN

        cleanup:
        userRepository.deleteById(student2.getId())
    }

}

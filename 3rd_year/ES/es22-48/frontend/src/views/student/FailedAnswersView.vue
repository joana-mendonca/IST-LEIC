<template>
    <div class="container">
        <v-card class="table">
            <v-card-title class = "justify-center">
              <v-spacer />
              <div>
              <span> Failed Answers </span>
              </div>
              <v-spacer />
              <v-spacer />
              <v-spacer />
              <div>
                  <v-btn
                      color="primary"
                      dark
                      data-cy="refreshButton"
                      @click="onFailedAnswersRefresh"
                  >Refresh
                  </v-btn>
              </div>
            </v-card-title>
            <v-data-table
                :headers="headers"
                :sort-by="['collected']"
                  sort-desc
                :items="failedAnswers"
                :items-per-page="15"
                :footer-props="{ itemsPerPageOptions: [15, 30, 50, 100] }"
                data-cy="failedAnswersTable"
            >
                <template v-slot:[`item.action`]="{ item }">
                    <v-tooltip bottom>
                        <template v-slot:activator="{ on }">
                        <v-icon
                            class="mr-2 action-button"
                            v-on="on"
                            data-cy="showStudentViewDialogButton"
                            @click="showStudentViewDialog(item)"
                            >school</v-icon
                        >
                        </template>
                        <span>Student View</span>
                    </v-tooltip>

                    <v-tooltip bottom>
                      <template v-slot:activator="{ on }">
                      <v-icon
                          class="mr-2 action-button"
                          v-on="on"
                          data-cy="deleteFailedAnswerButton"
                          @click="deleteFailedAnswer(item)"
                          color="red"
                          >delete</v-icon
                      >
                      </template>
                      <span>Delete Failed Answer</span>
                    </v-tooltip>
                </template>
                
            </v-data-table>

        <student-view-dialog
            v-if="statementQuestion && studentViewDialog"
            v-model="studentViewDialog"
            :statementQuestion="statementQuestion"
            v-on:close-show-question-dialog="onCloseStudentViewDialog"
        />
        </v-card>
    </div>
</template>

<script lang="ts">
import {Component, Prop, Vue } from 'vue-property-decorator';
import RemoteServices from '@/services/RemoteServices';
import StudentViewDialog from '@/views/teacher/questions/StudentViewDialog.vue';
import FailedAnswer from '@/models/dashboard/FailedAnswer';
import Question from '@/models/management/Question';
import StatementQuestion from '@/models/statement/StatementQuestion';

@Component({
    components: { 
        'student-view-dialog': StudentViewDialog
    },
})
export default class FailedAnswersView extends Vue {
  @Prop({ type: Number, required: true })
  readonly dashboardId!: number;
  @Prop({ type: String })
  readonly lastCheckFailedAnswers!: string;
  
  failedAnswers: FailedAnswer[] = [];
  statementQuestion: StatementQuestion | null = null;
  studentViewDialog: boolean = false;

  async created() {
    await this.$store.dispatch('loading');
    try {
        this.failedAnswers = await RemoteServices.getFailedAnswers(this.dashboardId);
    } catch (error) {
        await this.$store.dispatch('error', error);
    }
    await this.$store.dispatch('clearLoading');
  }

  async onFailedAnswersRefresh() {
    await this.$store.dispatch('loading');
    try {
        await RemoteServices.updateFailedAnswers(this.dashboardId);
        let lastCheck = (await RemoteServices.getUserDashboard()).lastCheckFailedAnswers;
        this.$emit('refresh', lastCheck);
        this.failedAnswers = await RemoteServices.getFailedAnswers(this.dashboardId);
    } catch (error) {
        await this.$store.dispatch('error', error);
    }
    await this.$store.dispatch('clearLoading');
  }

  async showStudentViewDialog(failedAnswer: FailedAnswer) {
    let question: Question = failedAnswer.questionAnswerDto.question;
    if (question.id) {
      try {
        this.statementQuestion = await RemoteServices.getStatementQuestion(question.id);
        this.studentViewDialog = true;
      } catch (error) {
        await this.$store.dispatch('error', error);
      }
    }
  }

  async deleteFailedAnswer(failedAnswer: FailedAnswer) {
    try {
      await RemoteServices.deleteFailedAnswer(this.dashboardId, failedAnswer.id);
      this.failedAnswers = await RemoteServices.getFailedAnswers(this.dashboardId);
    } catch (error) {
      await this.$store.dispatch('error', error);
    }
  }

  onCloseStudentViewDialog() {
    this.statementQuestion = null;
    this.studentViewDialog = false;
  }

  beautify(answered: Boolean) : string {
    if (answered) {
      return 'yes';
    }
    else {
      return 'no';
    }
  }

  headers: object = [
    {
      text: 'Actions',
      value: 'action',
      align: 'left',
      width: '10%',
      sortable: false,
    },
    {
        text: 'Question',
        value: 'questionAnswerDto.question.title',
        align: 'left',
        width: '5px',
    },
    {
        text: 'Answered',
        value: 'answeredString',
        align: 'center',
        width: '5px',
    },
    {
        text: 'Collected',
        value: 'collected',
        align: 'right',
        width: '10%',
    },
  ];
}




</script>
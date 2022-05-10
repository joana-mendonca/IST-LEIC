<template>
  <v-card class="table">
    <v-data-table
      :headers="headers"
      :items="weeklyScores"
      :sort-by="['week']"
      sort-desc
      :mobile-breakpoint="0"
      :items-per-page="15"
      :footer-props="{ itemsPerPageOptions: [15, 30, 50, 100] }"
    >
      <template v-slot:top>
        <v-card-title>
          <h3>Weekly Scores</h3>
          <v-spacer/>
          <v-btn color="primary" dark @click="updateNGetWeeklyScores"
            >Refresh</v-btn
          >
        </v-card-title>
      </template>
      
      <template v-slot:[`item.action`]="{item}">
          <v-tooltip bottom v-if="item.numberAnswered > 0">
            <template v-slot:activator="{ on }">
              <v-icon
                class="mr-2 action-button"
                v-on="on"
                data-cy="deleteWeeklyScoreButton"
                @click="deleteWeeklyScore(item)"
                color="red"
                >delete</v-icon
              >
            </template>
            <span>Delete Weekly Score</span>
          </v-tooltip>
      </template>
    </v-data-table>
    <footer>
    </footer>
  </v-card>
</template>

<script lang="ts">
import { Component, Vue, Watch } from 'vue-property-decorator';
import WeeklyScores from '@/models/dashboard/WeeklyScores';
import RemoteServices from '@/services/RemoteServices';

@Component({
  components: {
  },
})
export default class WeeklyScoresView extends Vue {
    weeklyScores: WeeklyScores[] = [];
    headers = WeeklyScores.weeklyScoreHeader;

    async created() {
        await this.getWeeklyScores();
    }

    async getWeeklyScores() {
        const { 
            $attrs : { 
                dashboardId 
            },
            $store : {
                dispatch
            }
        } = this;

        await RemoteServices.updateWeeklyScore(parseInt(dashboardId));
        await dispatch('loading');

        try {
            this.weeklyScores = await RemoteServices.getWeeklyScores(parseInt(dashboardId));
        } catch (error) {
            await dispatch('error', error);
        }

        await dispatch('clearLoading');
    }

    async updateNGetWeeklyScores() {
        await this.getWeeklyScores();
    }

    async deleteWeeklyScore(wkScore: WeeklyScores) {
        if( wkScore.id && confirm('Are you sure you want to delete this Weekly Score?')) {
            try {
                await RemoteServices.deleteWeeklyScore(wkScore.id);
                await RemoteServices.updateWeeklyScore(parseInt(this.$attrs.dashboardId));
            } catch(error) {
                await this.$store.dispatch('error', error);
            }
        }
    }
}

</script>

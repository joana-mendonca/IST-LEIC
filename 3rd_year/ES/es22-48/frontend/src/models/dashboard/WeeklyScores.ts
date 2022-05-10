export default class WeeklyScores {
  id!: number;
  numberAnswered!: number;
  uniquelyAnswered!: number;
  percentageCorrect!: number;
  week!: string;

  constructor(jsonObj?: WeeklyScores) {
    if (jsonObj) {
      this.id = jsonObj.id;
      this.numberAnswered = jsonObj.numberAnswered;
      this.uniquelyAnswered = jsonObj.uniquelyAnswered;
      this.percentageCorrect = jsonObj.percentageCorrect;
      this.week = jsonObj.week;
    }
  }

  static weeklyScoreHeader = [
    {
      text: 'Actions',
      value: 'action',
      align: 'left',
      width: '5px',
      sortable: false,
    },
    { text: 'Week', value: 'week', align: 'center', width: '5%' },
    { text: 'Number Answered', value: 'numberAnswered', align: 'center', width: '30%' },
    {
      text: 'Uniquely Answered',
      value: 'uniquelyAnswered',
      align: 'center',
      width: '170px',
      minWidth: '170px',
    },
    {
      text: 'Percentage Answered',
      value: 'percentageCorrect',
      align: 'center',
      sortable: false,
      width: '35%',
    },
  ];
}

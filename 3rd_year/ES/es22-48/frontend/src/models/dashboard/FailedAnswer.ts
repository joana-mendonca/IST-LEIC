import { ISOtoString } from '@/services/ConvertDateService';
import { QuestionAnswer } from '@/models/management/QuestionAnswer';

export default class FailedAnswer {
  id!: number;
  answered!: boolean;
  answeredString!: string;
  collected!: string;
  questionAnswerDto!: QuestionAnswer; 

  constructor(jsonObj?: FailedAnswer) {
    if (jsonObj) {
        this.id = jsonObj.id;
        this.questionAnswerDto = new QuestionAnswer(jsonObj.questionAnswerDto);
        this.questionAnswerDto.question;
        this.answered = jsonObj.answered;
        this.answeredString = FailedAnswer.beautifyBoolean(this.answered);
        this.collected = ISOtoString(jsonObj.collected);
    }
  }

  static beautifyBoolean(bool: Boolean): string {
    if (bool) {
      return 'Yes';
    }
    else {
      return 'No';
    }
  }
}

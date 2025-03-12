import { Controller, Get, Redirect } from '@nestjs/common';
import { exit } from 'process';

@Controller()
export class AppController {
  @Get()
  @Redirect('/login')
  landing() { }

  @Get('/crash')
  crash() {
    exit(-1);
  }
}

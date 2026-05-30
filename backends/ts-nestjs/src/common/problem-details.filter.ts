import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { Response } from 'express';

@Catch()
export class ProblemDetailsFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost): void {
    const response = host.switchToHttp().getResponse<Response>();

    const status =
      exception instanceof HttpException
        ? exception.getStatus()
        : HttpStatus.INTERNAL_SERVER_ERROR;

    let title = 'Internal Server Error';
    let detail: string | undefined;

    if (exception instanceof HttpException) {
      const body = exception.getResponse();
      if (typeof body === 'string') {
        detail = body;
      } else {
        const b = body as { error?: string; message?: string | string[] };
        if (typeof b.error === 'string') {
          title = b.error;
        }
        detail = Array.isArray(b.message) ? b.message.join('; ') : b.message;
      }
    }

    response
      .status(status)
      .type('application/problem+json')
      .json({ status, title, detail });
  }
}

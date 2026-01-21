import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Request, Response } from 'express';
import { QueryFailedError } from 'typeorm';
import { BusinessException } from '../exceptions/business.exception';
import { ValidationError as ClassValidationError } from 'class-validator';

interface ErrorResponse {
  success: false;
  message: string;
  error_code?: string;
  errors?: Array<{ field: string; message: string }>;
  details?: Record<string, unknown>;
  path: string;
  timestamp: string;
}

@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(GlobalExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    const errorResponse = this.buildErrorResponse(exception, request);

    // Log error with appropriate level
    if (errorResponse.status >= 500) {
      this.logger.error(
        `${request.method} ${request.url} - ${errorResponse.status}`,
        exception instanceof Error ? exception.stack : String(exception),
      );
    } else {
      this.logger.warn(
        `${request.method} ${request.url} - ${errorResponse.status}: ${errorResponse.body.message}`,
      );
    }

    response.status(errorResponse.status).json(errorResponse.body);
  }

  private buildErrorResponse(
    exception: unknown,
    request: Request,
  ): { status: number; body: ErrorResponse } {
    const timestamp = new Date().toISOString();
    const path = request.url;

    // Handle Business Exceptions (custom exceptions)
    if (exception instanceof BusinessException) {
      const exceptionResponse = exception.getResponse() as Record<string, unknown>;
      return {
        status: exception.getStatus(),
        body: {
          success: false,
          message: exceptionResponse.message as string,
          error_code: exceptionResponse.errorCode as string,
          details: exceptionResponse.details as Record<string, unknown>,
          path,
          timestamp,
        },
      };
    }

    // Handle standard HTTP exceptions
    if (exception instanceof HttpException) {
      const status = exception.getStatus();
      const exceptionResponse = exception.getResponse();

      if (typeof exceptionResponse === 'string') {
        return {
          status,
          body: {
            success: false,
            message: exceptionResponse,
            path,
            timestamp,
          },
        };
      }

      const responseObj = exceptionResponse as Record<string, unknown>;

      // Handle class-validator errors
      if (Array.isArray(responseObj.message)) {
        const validationErrors = this.formatValidationErrors(responseObj.message);
        return {
          status,
          body: {
            success: false,
            message: 'Validation failed',
            error_code: 'VALIDATION_ERROR',
            errors: validationErrors,
            path,
            timestamp,
          },
        };
      }

      return {
        status,
        body: {
          success: false,
          message: (responseObj.message as string) || 'An error occurred',
          error_code: responseObj.error as string,
          path,
          timestamp,
        },
      };
    }

    // Handle TypeORM query errors
    if (exception instanceof QueryFailedError) {
      const pgError = exception as QueryFailedError & {
        code?: string;
        constraint?: string;
      };

      // Unique constraint violation
      if (pgError.code === '23505') {
        return {
          status: HttpStatus.CONFLICT,
          body: {
            success: false,
            message: 'A resource with the specified values already exists',
            error_code: 'DUPLICATE_ENTRY',
            details: { constraint: pgError.constraint },
            path,
            timestamp,
          },
        };
      }

      // Foreign key constraint violation
      if (pgError.code === '23503') {
        return {
          status: HttpStatus.BAD_REQUEST,
          body: {
            success: false,
            message: 'Referenced resource does not exist',
            error_code: 'FOREIGN_KEY_VIOLATION',
            details: { constraint: pgError.constraint },
            path,
            timestamp,
          },
        };
      }

      // Check constraint violation
      if (pgError.code === '23514') {
        return {
          status: HttpStatus.BAD_REQUEST,
          body: {
            success: false,
            message: 'Data validation constraint failed',
            error_code: 'CHECK_CONSTRAINT_VIOLATION',
            details: { constraint: pgError.constraint },
            path,
            timestamp,
          },
        };
      }
    }

    // Handle unknown errors
    const isDevelopment = process.env.NODE_ENV !== 'production';
    const errorMessage = exception instanceof Error ? exception.message : String(exception);
    
    return {
      status: HttpStatus.INTERNAL_SERVER_ERROR,
      body: {
        success: false,
        message: isDevelopment ? errorMessage : 'An unexpected error occurred',
        error_code: 'INTERNAL_SERVER_ERROR',
        ...(isDevelopment && exception instanceof Error && { details: { stack: exception.stack } }),
        path,
        timestamp,
      },
    };
  }

  private formatValidationErrors(
    messages: unknown[],
  ): Array<{ field: string; message: string }> {
    const errors: Array<{ field: string; message: string }> = [];

    for (const message of messages) {
      if (typeof message === 'string') {
        // Try to parse field name from message
        const match = message.match(/^(\w+)\s/);
        errors.push({
          field: match ? match[1] : 'unknown',
          message,
        });
      } else if (message instanceof ClassValidationError) {
        const constraints = message.constraints || {};
        for (const constraintMessage of Object.values(constraints)) {
          errors.push({
            field: message.property,
            message: constraintMessage,
    });
  }
}
    }

    return errors;
  }
}

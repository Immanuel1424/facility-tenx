"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var GlobalExceptionFilter_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.GlobalExceptionFilter = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("typeorm");
const business_exception_1 = require("../exceptions/business.exception");
const class_validator_1 = require("class-validator");
let GlobalExceptionFilter = GlobalExceptionFilter_1 = class GlobalExceptionFilter {
    constructor() {
        this.logger = new common_1.Logger(GlobalExceptionFilter_1.name);
    }
    catch(exception, host) {
        const ctx = host.switchToHttp();
        const response = ctx.getResponse();
        const request = ctx.getRequest();
        const errorResponse = this.buildErrorResponse(exception, request);
        if (errorResponse.status >= 500) {
            this.logger.error(`${request.method} ${request.url} - ${errorResponse.status}`, exception instanceof Error ? exception.stack : String(exception));
        }
        else {
            this.logger.warn(`${request.method} ${request.url} - ${errorResponse.status}: ${errorResponse.body.message}`);
        }
        response.status(errorResponse.status).json(errorResponse.body);
    }
    buildErrorResponse(exception, request) {
        const timestamp = new Date().toISOString();
        const path = request.url;
        if (exception instanceof business_exception_1.BusinessException) {
            const exceptionResponse = exception.getResponse();
            return {
                status: exception.getStatus(),
                body: {
                    success: false,
                    message: exceptionResponse.message,
                    error_code: exceptionResponse.errorCode,
                    details: exceptionResponse.details,
                    path,
                    timestamp,
                },
            };
        }
        if (exception instanceof common_1.HttpException) {
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
            const responseObj = exceptionResponse;
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
                    message: responseObj.message || 'An error occurred',
                    error_code: responseObj.error,
                    path,
                    timestamp,
                },
            };
        }
        if (exception instanceof typeorm_1.QueryFailedError) {
            const pgError = exception;
            if (pgError.code === '23505') {
                return {
                    status: common_1.HttpStatus.CONFLICT,
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
            if (pgError.code === '23503') {
                return {
                    status: common_1.HttpStatus.BAD_REQUEST,
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
            if (pgError.code === '23514') {
                return {
                    status: common_1.HttpStatus.BAD_REQUEST,
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
        const isDevelopment = process.env.NODE_ENV !== 'production';
        const errorMessage = exception instanceof Error ? exception.message : String(exception);
        return {
            status: common_1.HttpStatus.INTERNAL_SERVER_ERROR,
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
    formatValidationErrors(messages) {
        const errors = [];
        for (const message of messages) {
            if (typeof message === 'string') {
                const match = message.match(/^(\w+)\s/);
                errors.push({
                    field: match ? match[1] : 'unknown',
                    message,
                });
            }
            else if (message instanceof class_validator_1.ValidationError) {
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
};
exports.GlobalExceptionFilter = GlobalExceptionFilter;
exports.GlobalExceptionFilter = GlobalExceptionFilter = GlobalExceptionFilter_1 = __decorate([
    (0, common_1.Catch)()
], GlobalExceptionFilter);

import {
  ApiResponse,
  PaginatedData,
  PaginatedResponse,
  ValidationError,
} from '../interfaces/api-response.interface';

/**
 * API Response Builder Utility
 * Creates consistent API responses across the application
 */
export class ApiResponseUtil {
  static success<T>(data: T, message = 'Operation successful'): ApiResponse<T> {
    return {
      success: true,
      data,
      message,
      timestamp: new Date().toISOString(),
    };
  }

  static created<T>(data: T, message = 'Resource created successfully'): ApiResponse<T> {
    return {
      success: true,
      data,
      message,
      timestamp: new Date().toISOString(),
    };
  }

  static paginated<T>(
    items: T[],
    total: number,
    page: number,
    limit: number,
    message = 'Data retrieved successfully',
  ): PaginatedResponse<T> {
    const totalPages = Math.ceil(total / limit);
    const paginatedData: PaginatedData<T> = {
      items,
      total,
      page,
      limit,
      total_pages: totalPages,
      has_next: page < totalPages,
      has_previous: page > 1,
    };

    return {
      success: true,
      data: paginatedData,
      message,
      timestamp: new Date().toISOString(),
    };
  }

  static error(
    message: string,
    errors?: ValidationError[],
    path?: string,
  ): ApiResponse<null> {
    return {
      success: false,
      data: null,
      message,
      timestamp: new Date().toISOString(),
      path,
      errors,
    };
  }

  static noContent(message = 'Operation completed successfully'): ApiResponse<null> {
    return {
      success: true,
      data: null,
      message,
      timestamp: new Date().toISOString(),
    };
  }
}


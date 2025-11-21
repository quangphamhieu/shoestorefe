using System.Net;
using System.Text.Json;
using Microsoft.AspNetCore.Http;

namespace ShoeStore.API.Middleware
{
    public class ExceptionMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<ExceptionMiddleware> _logger;

        public ExceptionMiddleware(RequestDelegate next, ILogger<ExceptionMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            try
            {
                await _next(context);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unhandled exception");
                await HandleExceptionAsync(context, ex);
            }
        }

        private static Task HandleExceptionAsync(HttpContext context, Exception exception)
        {
            int statusCode = (int)HttpStatusCode.InternalServerError;

            if (exception is InvalidOperationException)
                statusCode = (int)HttpStatusCode.Conflict; // 409
            else if (exception is ArgumentException || exception is System.ComponentModel.DataAnnotations.ValidationException)
                statusCode = (int)HttpStatusCode.BadRequest; // 400
            else if (exception is UnauthorizedAccessException)
                statusCode = (int)HttpStatusCode.Unauthorized; // 401

            var result = JsonSerializer.Serialize(new { message = exception.Message });
            context.Response.ContentType = "application/json";
            context.Response.StatusCode = statusCode;
            return context.Response.WriteAsync(result);
        }
    }
}

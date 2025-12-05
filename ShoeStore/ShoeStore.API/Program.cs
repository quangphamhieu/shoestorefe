using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.OpenApi.Models;
using ShoeStore.Infrastructure.Extensions;
using ShoeStore.Infrastructure.Mail;
using ShoeStore.Infrastructure.Persistence.Interceptors;
using ShoeStore.Infrastructure.Security;
using ShoeStore.API.Middleware;
using System.Text;
using System.Text.Json;
namespace ShoeStore.API
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // Add services to the container.

            builder.Services.AddControllers()
                .AddJsonOptions(options =>
                {
                    options.JsonSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
                    options.JsonSerializerOptions.PropertyNameCaseInsensitive = true;
                });
            // Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen();
            builder.Services.Configure<MailSettings>(builder.Configuration.GetSection("MailSettings"));
            builder.Services.AddInfrastructure(builder.Configuration);
            builder.Services.AddCors(options =>
            {
                options.AddPolicy("AllowFlutterApp",
                    policy => policy
                        .AllowAnyOrigin() // hoặc chỉ định nếu bạn biết cụ thể origin, ví dụ: .WithOrigins("http://localhost:57439")
                        .AllowAnyHeader()
                        .AllowAnyMethod());
            });
            var jwtSettings = builder.Configuration.GetSection("Jwt");
            var key = Encoding.UTF8.GetBytes(jwtSettings["Key"]);
            builder.Services.AddAuthentication(options =>
            {
                options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
            }).AddJwtBearer(options =>
            {
                options.RequireHttpsMetadata = false;
                options.SaveToken = true;
                options.TokenValidationParameters = new Microsoft.IdentityModel.Tokens.TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidAudience = builder.Configuration["Jwt:Audience"],
                    ValidIssuer = builder.Configuration["Jwt:Issuer"],
                    IssuerSigningKey = new Microsoft.IdentityModel.Tokens.SymmetricSecurityKey(System.Text.Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"])),
                    ValidateLifetime = true
                };
            });
            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen(c =>
            {
                c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
                {
                    Description = "nhap token.",
                    Name = "Authorization",
                    In = ParameterLocation.Header,
                    Type = SecuritySchemeType.ApiKey
                });

                c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            new string[] {}
        }
    });
            });
            builder.Services.AddSingleton<JwtTokenGenerator>();
            builder.Services.AddSingleton<PasswordHelper>();
            builder.Services.AddAuthorization(options =>
            {
                // Product
                options.AddPolicy("PRODUCT_VIEW", p => p.RequireClaim("permission", "PRODUCT_VIEW"));
                options.AddPolicy("PRODUCT_CREATE", p => p.RequireClaim("permission", "PRODUCT_CREATE"));
                options.AddPolicy("PRODUCT_UPDATE", p => p.RequireClaim("permission", "PRODUCT_UPDATE"));
                options.AddPolicy("PRODUCT_DELETE", p => p.RequireClaim("permission", "PRODUCT_DELETE"));
                options.AddPolicy("PRODUCT_SEARCH", p => p.RequireClaim("permission", "PRODUCT_SEARCH"));
                options.AddPolicy("PRODUCT_SUGGEST", p => p.RequireClaim("permission", "PRODUCT_SUGGEST"));
                options.AddPolicy("PRODUCT_STORE_QUANTITY_MANAGE", p => p.RequireClaim("permission", "PRODUCT_STORE_QUANTITY_MANAGE"));

                // Promotion
                options.AddPolicy("PROMOTION_VIEW", p => p.RequireClaim("permission", "PROMOTION_VIEW"));
                options.AddPolicy("PROMOTION_CREATE", p => p.RequireClaim("permission", "PROMOTION_CREATE"));
                options.AddPolicy("PROMOTION_UPDATE", p => p.RequireClaim("permission", "PROMOTION_UPDATE"));
                options.AddPolicy("PROMOTION_DELETE", p => p.RequireClaim("permission", "PROMOTION_DELETE"));

                // Brand
                options.AddPolicy("BRAND_VIEW", p => p.RequireClaim("permission", "BRAND_VIEW"));
                options.AddPolicy("BRAND_CREATE", p => p.RequireClaim("permission", "BRAND_CREATE"));
                options.AddPolicy("BRAND_UPDATE", p => p.RequireClaim("permission", "BRAND_UPDATE"));
                options.AddPolicy("BRAND_DELETE", p => p.RequireClaim("permission", "BRAND_DELETE"));

                // Store
                options.AddPolicy("STORE_VIEW", p => p.RequireClaim("permission", "STORE_VIEW"));
                options.AddPolicy("STORE_CREATE", p => p.RequireClaim("permission", "STORE_CREATE"));
                options.AddPolicy("STORE_UPDATE", p => p.RequireClaim("permission", "STORE_UPDATE"));
                options.AddPolicy("STORE_DELETE", p => p.RequireClaim("permission", "STORE_DELETE"));

                // Supplier
                options.AddPolicy("SUPPLIER_VIEW", p => p.RequireClaim("permission", "SUPPLIER_VIEW"));
                options.AddPolicy("SUPPLIER_CREATE", p => p.RequireClaim("permission", "SUPPLIER_CREATE"));
                options.AddPolicy("SUPPLIER_UPDATE", p => p.RequireClaim("permission", "SUPPLIER_UPDATE"));
                options.AddPolicy("SUPPLIER_DELETE", p => p.RequireClaim("permission", "SUPPLIER_DELETE"));

                // Receipt
                options.AddPolicy("RECEIPT_VIEW", p => p.RequireClaim("permission", "RECEIPT_VIEW"));
                options.AddPolicy("RECEIPT_CREATE", p => p.RequireClaim("permission", "RECEIPT_CREATE"));
                options.AddPolicy("RECEIPT_UPDATE", p => p.RequireClaim("permission", "RECEIPT_UPDATE"));
                options.AddPolicy("RECEIPT_DELETE", p => p.RequireClaim("permission", "RECEIPT_DELETE"));

                // Order
                options.AddPolicy("ORDER_VIEW", p => p.RequireClaim("permission", "ORDER_VIEW"));
                options.AddPolicy("ORDER_CREATE", p => p.RequireClaim("permission", "ORDER_CREATE"));
                options.AddPolicy("ORDER_UPDATE", p => p.RequireClaim("permission", "ORDER_UPDATE"));
                options.AddPolicy("ORDER_DELETE", p => p.RequireClaim("permission", "ORDER_DELETE"));
                options.AddPolicy("ORDER_MANAGE_DETAILS", p => p.RequireClaim("permission", "ORDER_MANAGE_DETAILS"));

                // Notification
                options.AddPolicy("NOTIFICATION_VIEW", p => p.RequireClaim("permission", "NOTIFICATION_VIEW"));
                options.AddPolicy("NOTIFICATION_CREATE", p => p.RequireClaim("permission", "NOTIFICATION_CREATE"));
                options.AddPolicy("NOTIFICATION_DELETE", p => p.RequireClaim("permission", "NOTIFICATION_DELETE"));

                // Comment
                options.AddPolicy("COMMENT_VIEW", p => p.RequireClaim("permission", "COMMENT_VIEW"));
                options.AddPolicy("COMMENT_CREATE", p => p.RequireClaim("permission", "COMMENT_CREATE"));
                options.AddPolicy("COMMENT_UPDATE", p => p.RequireClaim("permission", "COMMENT_UPDATE"));
                options.AddPolicy("COMMENT_DELETE", p => p.RequireClaim("permission", "COMMENT_DELETE"));

                // Cart
                options.AddPolicy("CART_VIEW", p => p.RequireClaim("permission", "CART_VIEW"));
                options.AddPolicy("CART_CREATE", p => p.RequireClaim("permission", "CART_CREATE"));
                options.AddPolicy("CART_UPDATE", p => p.RequireClaim("permission", "CART_UPDATE"));
                options.AddPolicy("CART_DELETE", p => p.RequireClaim("permission", "CART_DELETE"));

                // User management
                options.AddPolicy("USER_VIEW", p => p.RequireClaim("permission", "USER_VIEW"));
                options.AddPolicy("USER_CREATE", p => p.RequireClaim("permission", "USER_CREATE"));
                options.AddPolicy("USER_UPDATE", p => p.RequireClaim("permission", "USER_UPDATE"));
                options.AddPolicy("USER_DELETE", p => p.RequireClaim("permission", "USER_DELETE"));

                // Roles & permissions / admin features
                options.AddPolicy("ROLE_MANAGE", p => p.RequireClaim("permission", "ROLE_MANAGE"));
                options.AddPolicy("PERMISSION_MANAGE", p => p.RequireClaim("permission", "PERMISSION_MANAGE"));

                // Dashboard & Audit
                options.AddPolicy("DASHBOARD_VIEW", p => p.RequireClaim("permission", "DASHBOARD_VIEW"));
                options.AddPolicy("AUDIT_VIEW", p => p.RequireClaim("permission", "AUDIT_VIEW"));
            });
            builder.Services.AddHttpContextAccessor();
            builder.Services.AddScoped<AuditInterceptor>();

            var app = builder.Build();

            // Configure the HTTP request pipeline.
            if (app.Environment.IsDevelopment())
            {
                app.UseSwagger();
                app.UseSwaggerUI();
            }
            app.UseCors("AllowFlutterApp");
            app.UseHttpsRedirection();

            // Global exception handling middleware
            app.UseMiddleware<ExceptionMiddleware>();

            app.UseAuthentication();
            app.UseAuthorization();


            app.MapControllers();

            app.Run();
        }
    }
}

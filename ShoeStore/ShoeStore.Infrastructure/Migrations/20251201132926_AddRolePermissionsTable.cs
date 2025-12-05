using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace ShoeStore.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddRolePermissionsTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Permissions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Code = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Permissions", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "RolePermissions",
                columns: table => new
                {
                    RoleId = table.Column<byte>(type: "tinyint", nullable: false),
                    PermissionId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RolePermissions", x => new { x.RoleId, x.PermissionId });
                    table.ForeignKey(
                        name: "FK_RolePermissions_Permissions_PermissionId",
                        column: x => x.PermissionId,
                        principalTable: "Permissions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_RolePermissions_Roles_RoleId",
                        column: x => x.RoleId,
                        principalTable: "Roles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.InsertData(
                table: "Permissions",
                columns: new[] { "Id", "Code", "Description" },
                values: new object[,]
                {
                    { 10, "PRODUCT_VIEW", "View products" },
                    { 11, "PRODUCT_CREATE", "Create product" },
                    { 12, "PRODUCT_UPDATE", "Update product" },
                    { 13, "PRODUCT_DELETE", "Delete product" },
                    { 14, "PROMOTION_VIEW", "View promotions" },
                    { 15, "PROMOTION_CREATE", "Create promotion" },
                    { 16, "PROMOTION_UPDATE", "Update promotion" },
                    { 17, "PROMOTION_DELETE", "Delete promotion" },
                    { 18, "BRAND_VIEW", "View brands" },
                    { 19, "BRAND_CREATE", "Create brand" },
                    { 20, "BRAND_UPDATE", "Update brand" },
                    { 21, "BRAND_DELETE", "Delete brand" },
                    { 22, "STORE_VIEW", "View stores" },
                    { 23, "STORE_CREATE", "Create store" },
                    { 24, "STORE_UPDATE", "Update store" },
                    { 25, "STORE_DELETE", "Delete store" },
                    { 26, "SUPPLIER_VIEW", "View suppliers" },
                    { 27, "SUPPLIER_CREATE", "Create supplier" },
                    { 28, "SUPPLIER_UPDATE", "Update supplier" },
                    { 29, "SUPPLIER_DELETE", "Delete supplier" },
                    { 30, "RECEIPT_VIEW", "View receipts" },
                    { 31, "RECEIPT_CREATE", "Create receipt" },
                    { 32, "RECEIPT_UPDATE", "Update receipt" },
                    { 33, "RECEIPT_DELETE", "Delete receipt" },
                    { 34, "ORDER_VIEW", "View orders" },
                    { 35, "ORDER_CREATE", "Create order" },
                    { 36, "ORDER_UPDATE", "Update order" },
                    { 37, "ORDER_DELETE", "Delete order" },
                    { 38, "NOTIFICATION_VIEW", "View notifications" },
                    { 39, "NOTIFICATION_CREATE", "Create notification" },
                    { 40, "NOTIFICATION_DELETE", "Delete notification" },
                    { 41, "COMMENT_VIEW", "View comments" },
                    { 42, "COMMENT_CREATE", "Create comment" },
                    { 43, "COMMENT_UPDATE", "Update comment" },
                    { 44, "COMMENT_DELETE", "Delete comment" },
                    { 45, "CART_VIEW", "View cart" },
                    { 46, "CART_CREATE", "Create/Add to cart" },
                    { 47, "CART_UPDATE", "Update cart item" },
                    { 48, "CART_DELETE", "Remove from cart / clear cart" },
                    { 49, "USER_VIEW", "View users" },
                    { 50, "USER_CREATE", "Create user" },
                    { 51, "USER_UPDATE", "Update user" },
                    { 52, "USER_DELETE", "Delete user" },
                    { 53, "ROLE_MANAGE", "Manage roles" },
                    { 54, "PERMISSION_MANAGE", "Manage permissions" },
                    { 55, "DASHBOARD_VIEW", "View dashboard" },
                    { 56, "AUDIT_VIEW", "View audit logs" },
                    { 57, "PRODUCT_SEARCH", "Search products" },
                    { 58, "PRODUCT_SUGGEST", "Suggest product keywords" },
                    { 59, "PRODUCT_STORE_QUANTITY_MANAGE", "Manage product-store quantity" },
                    { 60, "ORDER_MANAGE_DETAILS", "Manage order details/status" }
                });

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: (byte)2,
                column: "Name",
                value: "Admin");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1L,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 12, 1, 20, 29, 23, 988, DateTimeKind.Local).AddTicks(2974), "AQAAAAIAAYagAAAAEJHj9KC5ohdyR9cx+RK/ubS9Ao649iV3L5s9AYGW+ItPmjqAP0reOzoMAsjtJZon4A==" });

            migrationBuilder.InsertData(
                table: "RolePermissions",
                columns: new[] { "PermissionId", "RoleId" },
                values: new object[,]
                {
                    { 10, (byte)1 },
                    { 11, (byte)1 },
                    { 12, (byte)1 },
                    { 13, (byte)1 },
                    { 14, (byte)1 },
                    { 15, (byte)1 },
                    { 16, (byte)1 },
                    { 17, (byte)1 },
                    { 18, (byte)1 },
                    { 19, (byte)1 },
                    { 20, (byte)1 },
                    { 21, (byte)1 },
                    { 22, (byte)1 },
                    { 23, (byte)1 },
                    { 24, (byte)1 },
                    { 25, (byte)1 },
                    { 26, (byte)1 },
                    { 27, (byte)1 },
                    { 28, (byte)1 },
                    { 29, (byte)1 },
                    { 30, (byte)1 },
                    { 31, (byte)1 },
                    { 32, (byte)1 },
                    { 33, (byte)1 },
                    { 34, (byte)1 },
                    { 35, (byte)1 },
                    { 36, (byte)1 },
                    { 37, (byte)1 },
                    { 38, (byte)1 },
                    { 39, (byte)1 },
                    { 40, (byte)1 },
                    { 41, (byte)1 },
                    { 42, (byte)1 },
                    { 43, (byte)1 },
                    { 44, (byte)1 },
                    { 45, (byte)1 },
                    { 46, (byte)1 },
                    { 47, (byte)1 },
                    { 48, (byte)1 },
                    { 49, (byte)1 },
                    { 50, (byte)1 },
                    { 51, (byte)1 },
                    { 52, (byte)1 },
                    { 53, (byte)1 },
                    { 54, (byte)1 },
                    { 55, (byte)1 },
                    { 56, (byte)1 },
                    { 57, (byte)1 },
                    { 58, (byte)1 },
                    { 59, (byte)1 },
                    { 60, (byte)1 },
                    { 10, (byte)2 },
                    { 11, (byte)2 },
                    { 12, (byte)2 },
                    { 13, (byte)2 },
                    { 14, (byte)2 },
                    { 15, (byte)2 },
                    { 16, (byte)2 },
                    { 17, (byte)2 },
                    { 18, (byte)2 },
                    { 19, (byte)2 },
                    { 20, (byte)2 },
                    { 21, (byte)2 },
                    { 22, (byte)2 },
                    { 23, (byte)2 },
                    { 24, (byte)2 },
                    { 25, (byte)2 },
                    { 26, (byte)2 },
                    { 27, (byte)2 },
                    { 28, (byte)2 },
                    { 29, (byte)2 },
                    { 30, (byte)2 },
                    { 31, (byte)2 },
                    { 32, (byte)2 },
                    { 33, (byte)2 },
                    { 34, (byte)2 },
                    { 35, (byte)2 },
                    { 36, (byte)2 },
                    { 37, (byte)2 },
                    { 38, (byte)2 },
                    { 39, (byte)2 },
                    { 40, (byte)2 },
                    { 41, (byte)2 },
                    { 42, (byte)2 },
                    { 43, (byte)2 },
                    { 44, (byte)2 },
                    { 45, (byte)2 },
                    { 46, (byte)2 },
                    { 47, (byte)2 },
                    { 48, (byte)2 },
                    { 49, (byte)2 },
                    { 50, (byte)2 },
                    { 51, (byte)2 },
                    { 52, (byte)2 },
                    { 53, (byte)2 },
                    { 55, (byte)2 },
                    { 57, (byte)2 },
                    { 58, (byte)2 },
                    { 59, (byte)2 },
                    { 60, (byte)2 },
                    { 10, (byte)3 },
                    { 18, (byte)3 },
                    { 22, (byte)3 },
                    { 26, (byte)3 },
                    { 34, (byte)3 },
                    { 35, (byte)3 },
                    { 36, (byte)3 },
                    { 41, (byte)3 },
                    { 42, (byte)3 },
                    { 43, (byte)3 },
                    { 45, (byte)3 },
                    { 55, (byte)3 },
                    { 57, (byte)3 },
                    { 58, (byte)3 },
                    { 60, (byte)3 },
                    { 10, (byte)4 },
                    { 34, (byte)4 },
                    { 35, (byte)4 },
                    { 42, (byte)4 },
                    { 45, (byte)4 },
                    { 46, (byte)4 },
                    { 47, (byte)4 },
                    { 48, (byte)4 }
                });

            migrationBuilder.CreateIndex(
                name: "IX_RolePermissions_PermissionId",
                table: "RolePermissions",
                column: "PermissionId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "RolePermissions");

            migrationBuilder.DropTable(
                name: "Permissions");

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: (byte)2,
                column: "Name",
                value: "Adminitrator");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1L,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 11, 21, 7, 9, 27, 487, DateTimeKind.Local).AddTicks(2874), "AQAAAAIAAYagAAAAELZZ968zrUp4oUI9QSnZT9TQCym1i009TBtNaIeWa+TaZAyyrfYjGlP3IIegJIzZ3w==" });
        }
    }
}

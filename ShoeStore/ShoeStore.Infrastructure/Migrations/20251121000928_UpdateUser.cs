using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ShoeStore.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class UpdateUser : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1L,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 11, 21, 7, 9, 27, 487, DateTimeKind.Local).AddTicks(2874), "AQAAAAIAAYagAAAAELZZ968zrUp4oUI9QSnZT9TQCym1i009TBtNaIeWa+TaZAyyrfYjGlP3IIegJIzZ3w==" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1L,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 11, 20, 23, 37, 43, 412, DateTimeKind.Local).AddTicks(2621), "AQAAAAIAAYagAAAAEFByDzaV+dbVqAfSJshn5hDeJ1kQ+s8WYQJfRo3sk04MtR9EDW1SbmG5AMMa86qazQ==" });
        }
    }
}

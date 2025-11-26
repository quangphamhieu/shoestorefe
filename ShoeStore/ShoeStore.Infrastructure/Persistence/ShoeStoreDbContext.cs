using Microsoft.EntityFrameworkCore;
using ShoeStore.Domain.Entities;
using ShoeStore.Infrastructure.Persistence.Interceptors;
using ShoeStore.Infrastructure.Security;

namespace ShoeStore.Infrastructure.Persistence
{
    public class ShoeStoreDbContext : DbContext
    {
        private readonly AuditInterceptor _auditInterceptor;
        public ShoeStoreDbContext(DbContextOptions<ShoeStoreDbContext> options, AuditInterceptor auditInterceptor) : base(options)
        {
            _auditInterceptor = auditInterceptor;
        }

        // DbSets
        public DbSet<Status> Statuses { get; set; } = null!;
        public DbSet<Store> Stores { get; set; } = null!;
        public DbSet<Supplier> Suppliers { get; set; } = null!;
        public DbSet<User> Users { get; set; } = null!;
        public DbSet<Role> Roles { get; set; } = null!;
        public DbSet<Product> Products { get; set; } = null!;
        public DbSet<Receipt> Receipts { get; set; } = null!;
        public DbSet<ReceiptDetail> ReceiptDetails { get; set; } = null!;
        public DbSet<Promotion> Promotions { get; set; } = null!;
        public DbSet<PromotionProduct> PromotionProducts { get; set; } = null!;
        public DbSet<Order> Orders { get; set; } = null!;
        public DbSet<OrderDetail> OrderDetails { get; set; } = null!;
        public DbSet<Notification> Notifications { get; set; } = null!;
        public DbSet<Comment> Comments { get; set; } = null!;
        public DbSet<Cart> Carts { get; set; } = null!;
        public DbSet<CartItem> CartItems { get; set; } = null!;
        public DbSet<Brand> Brands { get; set; } = null!;
        public DbSet<AuditLog> AuditLogs { get; set; } = null!;
        public DbSet<StoreProduct> StoreProducts { get; set; } = null!;
        public DbSet<PromotionStore> PromotionStores { get; set; } = null!;
        public DbSet<RolePermission> RolePermissions { get; set; } = null!;
        public DbSet<Permission> Permissions { get; set; } = null!;


        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            optionsBuilder.AddInterceptors(_auditInterceptor);
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // ---------- Status ----------
            modelBuilder.Entity<Status>(entity =>
            {
                entity.ToTable("Statuses");
                entity.HasKey(s => s.Id);
                entity.Property(s => s.Code).IsRequired().HasMaxLength(50);
                entity.Property(s => s.Name).IsRequired().HasMaxLength(200);
                entity.Property(s => s.Description).HasMaxLength(1000);
                entity.HasIndex(s => s.Code).IsUnique(false); // nếu bạn muốn unique thì IsUnique(true)
            });

            // ---------- Role ----------
            modelBuilder.Entity<Role>(entity =>
            {
                entity.ToTable("Roles");
                entity.HasKey(r => r.Id);
                entity.Property(r => r.Code).IsRequired().HasMaxLength(50);
                entity.Property(r => r.Name).IsRequired().HasMaxLength(200);
            });

            // ---------- Store ----------
            modelBuilder.Entity<Store>(entity =>
            {
                entity.ToTable("Stores");
                entity.HasKey(s => s.Id);
                entity.Property(s => s.Code).HasMaxLength(50);
                entity.Property(s => s.Name).IsRequired().HasMaxLength(250);
                entity.Property(s => s.Address).HasMaxLength(500);
                entity.Property(s => s.Phone).HasMaxLength(50);
                entity.Property(s => s.CreatedAt).HasDefaultValueSql("GETUTCDATE()");

                // Add unique indexes for Code and Name
                entity.HasIndex(s => s.Code).IsUnique(true);
                entity.HasIndex(s => s.Name).IsUnique(true);

                entity.HasOne(s => s.Status)
                      .WithMany(st => st.Stores)
                      .HasForeignKey(s => s.StatusId)
                      .OnDelete(DeleteBehavior.Restrict);

                entity.HasMany(s => s.Users)
                      .WithOne(u => u.Store)
                      .HasForeignKey(u => u.StoreId)
                      .OnDelete(DeleteBehavior.SetNull);

                entity.HasMany(s => s.Orders)
                      .WithOne(o => o.Store)
                      .HasForeignKey(o => o.StoreId)
                      .OnDelete(DeleteBehavior.SetNull);

                // ✅ New many-to-many via StoreProduct
                entity.HasMany(s => s.StoreProducts)
                      .WithOne(sp => sp.Store)
                      .HasForeignKey(sp => sp.StoreId);

                entity.HasMany(s => s.PromotionStores)
                      .WithOne(ps => ps.Store)
                      .HasForeignKey(ps => ps.StoreId);
            });


            modelBuilder.Entity<StoreProduct>(entity =>
            {
                entity.ToTable("StoreProducts");
                entity.HasKey(sp => new { sp.StoreId, sp.ProductId });

                entity.Property(sp => sp.Quantity).IsRequired();
                entity.Property(sp => sp.SalePrice).HasColumnType("decimal(18,2)");

                entity.HasOne(sp => sp.Store)
                      .WithMany(s => s.StoreProducts)
                      .HasForeignKey(sp => sp.StoreId);

                entity.HasOne(sp => sp.Product)
                      .WithMany(p => p.StoreProducts)
                      .HasForeignKey(sp => sp.ProductId);
            });

            // ---------- Supplier ----------
            modelBuilder.Entity<Supplier>(entity =>
            {
                entity.ToTable("Suppliers");
                entity.HasKey(s => s.Id);
                entity.Property(s => s.Code).HasMaxLength(50);
                entity.Property(s => s.Name).IsRequired().HasMaxLength(250);
                entity.Property(s => s.ContactInfo).HasMaxLength(1000);

                // Add unique index for Code and Name
                entity.HasIndex(s => s.Code).IsUnique(true);
                entity.HasIndex(s => s.Name).IsUnique(true);

                // Supplier.Status
                entity.HasOne(s => s.Status)
                      .WithMany(st => st.Suppliers)
                      .HasForeignKey(s => s.StatusId)
                      .OnDelete(DeleteBehavior.Restrict);

                // Products relation (Supplier may have many Products)
                entity.HasMany(s => s.Products)
                      .WithOne(p => p.Supplier)
                      .HasForeignKey(p => p.SupplierId)
                      .OnDelete(DeleteBehavior.SetNull); // supplier nullable on Product
            });

            // ---------- User ----------
            modelBuilder.Entity<User>(entity =>
            {
                entity.ToTable("Users");
                entity.HasKey(u => u.Id);
                entity.Property(u => u.FullName).IsRequired().HasMaxLength(250);
                entity.Property(u => u.Phone).IsRequired().HasMaxLength(50);
                entity.Property(u => u.Email).HasMaxLength(250);
                entity.Property(u => u.PasswordHash).IsRequired();
                entity.Property(u => u.CreatedAt).HasDefaultValueSql("GETUTCDATE()");

                entity.HasOne(u => u.Role)
                      .WithMany(r => r.Users)
                      .HasForeignKey(u => u.RoleId)
                      .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(u => u.Store)
                      .WithMany(s => s.Users)
                      .HasForeignKey(u => u.StoreId)
                      .OnDelete(DeleteBehavior.SetNull);

                entity.HasOne(u => u.Status)
                      .WithMany(st => st.Users)
                      .HasForeignKey(u => u.StatusId)
                      .OnDelete(DeleteBehavior.Restrict);

                entity.HasIndex(u => u.Phone).IsUnique(false); // nếu phone phải unique => IsUnique(true)
            });

            // ---------- Brand ----------
            modelBuilder.Entity<Brand>(entity =>
            {
                entity.ToTable("Brands");
                entity.HasKey(b => b.Id);
                entity.Property(b => b.Code).HasMaxLength(50);
                entity.Property(b => b.Name).IsRequired().HasMaxLength(200);
                entity.Property(b => b.Description).HasMaxLength(1000);

                // Add unique index on Code and Name to enforce uniqueness
                entity.HasIndex(b => b.Code).IsUnique(true);
                entity.HasIndex(b => b.Name).IsUnique(true);

                entity.HasOne(b => b.Status)
                      .WithMany(s => s.Brands)
                      .HasForeignKey(b => b.StatusId)
                      .OnDelete(DeleteBehavior.Restrict);
            });

            // ---------- Product ----------
            modelBuilder.Entity<Product>(entity =>
            {
                entity.ToTable("Products");
                entity.HasKey(p => p.Id);
                entity.Property(p => p.SKU).HasMaxLength(500);
                entity.Property(p => p.Name).IsRequired().HasMaxLength(500);
                entity.Property(p => p.Color).HasMaxLength(100);
                entity.Property(p => p.Size).HasMaxLength(100);
                entity.Property(p => p.Description).HasMaxLength(2000);
                entity.Property(p => p.ImageUrl).HasMaxLength(1000);
                entity.Property(p => p.CreatedAt).HasDefaultValueSql("GETUTCDATE()");

                // Prices
                entity.Property(p => p.CostPrice).HasColumnType("decimal(18,2)");
                entity.Property(p => p.OriginalPrice).HasColumnType("decimal(18,2)");

                entity.HasIndex(p => p.SKU).IsUnique(); // SKU unique

                // Relations
                entity.HasOne(p => p.Brand)
                      .WithMany(b => b.Products)
                      .HasForeignKey(p => p.BrandId)
                      .OnDelete(DeleteBehavior.SetNull);

                entity.HasOne(p => p.Supplier)
                      .WithMany(s => s.Products)
                      .HasForeignKey(p => p.SupplierId)
                      .OnDelete(DeleteBehavior.SetNull);

                entity.HasOne(p => p.Status)
                      .WithMany(st => st.Products)
                      .HasForeignKey(p => p.StatusId)
                      .OnDelete(DeleteBehavior.Restrict);

                // ✅ New many-to-many via StoreProduct
                entity.HasMany(p => p.StoreProducts)
                      .WithOne(sp => sp.Product)
                      .HasForeignKey(sp => sp.ProductId);
            });


            // ---------- Receipt ----------
            modelBuilder.Entity<Receipt>(entity =>
            {
                entity.ToTable("Receipts");
                entity.HasKey(r => r.Id);
                entity.Property(r => r.ReceiptNumber).IsRequired().HasMaxLength(100);
                entity.Property(r => r.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
                entity.Property(r => r.TotalAmount).HasColumnType("decimal(18,2)").HasDefaultValue(0m);
                entity.Property(r => r.ReceivedDate).HasColumnType("datetime2").IsRequired(false);

                entity.HasIndex(r => r.ReceiptNumber).IsUnique();

                entity.HasOne(r => r.Supplier)
                      .WithMany() // nếu Supplier chưa có navigation
                      .HasForeignKey(r => r.SupplierId)
                      .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(r => r.Creator)
                      .WithMany() // nếu User chưa có navigation
                      .HasForeignKey(r => r.CreatedBy)
                      .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(r => r.Store)
                      .WithMany()
                      .HasForeignKey(r => r.StoreId)
                      .OnDelete(DeleteBehavior.SetNull);

                entity.HasOne(r => r.Status)
                      .WithMany(st => st.Receipts)
                      .HasForeignKey(r => r.StatusId)
                      .OnDelete(DeleteBehavior.Restrict);

                entity.HasMany(r => r.ReceiptDetails)
                      .WithOne(rd => rd.Receipt)
                      .HasForeignKey(rd => rd.ReceiptId)
                      .OnDelete(DeleteBehavior.Cascade);
            });

            // ---------- ReceiptDetail ----------
            modelBuilder.Entity<ReceiptDetail>(entity =>
            {
                entity.ToTable("ReceiptDetails");
                entity.HasKey(rd => rd.Id);

                entity.Property(rd => rd.QuantityOrdered).IsRequired();
                entity.Property(rd => rd.ReceivedQuantity).IsRequired(false);
                entity.Property(rd => rd.UnitPrice).HasColumnType("decimal(18,2)").IsRequired();

                entity.HasOne(rd => rd.Product)
                      .WithMany()
                      .HasForeignKey(rd => rd.ProductId)
                      .OnDelete(DeleteBehavior.Restrict);
            });

            // ---------- Promotion ----------
            modelBuilder.Entity<Promotion>(entity =>
            {
                entity.ToTable("Promotions");
                entity.HasKey(p => p.Id);
                entity.Property(p => p.Code).HasMaxLength(100);
                entity.Property(p => p.Name).IsRequired().HasMaxLength(300);
                entity.Property(p => p.StartDate).IsRequired();
                entity.Property(p => p.EndDate).IsRequired();

                // Add unique indexes for Code and Name
                entity.HasIndex(p => p.Code).IsUnique(true);
                entity.HasIndex(p => p.Name).IsUnique(true);

                entity.HasOne(p => p.Status)
                      .WithMany(st => st.Promotions)
                      .HasForeignKey(p => p.StatusId)
                      .OnDelete(DeleteBehavior.Restrict);

                entity.HasMany(p => p.PromotionProducts)
                      .WithOne(pp => pp.Promotion)
                      .HasForeignKey(pp => pp.PromotionId)
                      .OnDelete(DeleteBehavior.Cascade);

                entity.HasMany(p => p.PromotionStores)
                      .WithOne(ps => ps.Promotion)
                      .HasForeignKey(ps => ps.PromotionId)
                      .OnDelete(DeleteBehavior.Cascade);
            });

            modelBuilder.Entity<PromotionStore>(entity =>
            {
                entity.ToTable("PromotionStores");
                entity.HasKey(ps => new { ps.PromotionId, ps.StoreId });

                entity.HasOne(ps => ps.Promotion)
                      .WithMany(p => p.PromotionStores)
                      .HasForeignKey(ps => ps.PromotionId);

                entity.HasOne(ps => ps.Store)
                      .WithMany(s => s.PromotionStores)
                      .HasForeignKey(ps => ps.StoreId);
            });

            // ---------- PromotionProduct ----------
            modelBuilder.Entity<PromotionProduct>(entity =>
            {
                entity.ToTable("PromotionProducts");
                entity.HasKey(pp => pp.Id);
                entity.Property(pp => pp.DiscountPercent).HasColumnType("decimal(5,2)");
                entity.HasOne(pp => pp.Product)
                      .WithMany()
                      .HasForeignKey(pp => pp.ProductId)
                      .OnDelete(DeleteBehavior.Restrict);
            });

            // ---------- Order ----------
            modelBuilder.Entity<Order>(entity =>
            {
                entity.ToTable("Orders");
                entity.HasKey(o => o.Id);
                entity.Property(o => o.OrderNumber).IsRequired().HasMaxLength(100);
                entity.Property(o => o.TotalAmount).HasColumnType("decimal(18,2)");
                entity.Property(o => o.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
                entity.Property(o => o.UpdatedAt).IsRequired(false);

                // Customer (required)
                entity.HasOne(o => o.Customer)
                      .WithMany()
                      .HasForeignKey(o => o.CustomerId)
                      .OnDelete(DeleteBehavior.Restrict);

                // Creator (optional)
                entity.HasOne(o => o.Creator)
                      .WithMany()
                      .HasForeignKey(o => o.CreatedBy)
                      .OnDelete(DeleteBehavior.SetNull);

                entity.HasOne(o => o.Store)
                      .WithMany(s => s.Orders)
                      .HasForeignKey(o => o.StoreId)
                      .OnDelete(DeleteBehavior.SetNull);

                entity.HasOne(o => o.Status)
                      .WithMany(st => st.Orders)
                      .HasForeignKey(o => o.StatusId)
                      .OnDelete(DeleteBehavior.Restrict);

                entity.HasMany(o => o.OrderDetails)
                      .WithOne(od => od.Order)
                      .HasForeignKey(od => od.OrderId)
                      .OnDelete(DeleteBehavior.Cascade);

                // unique index on OrderNumber if desired:
                entity.HasIndex(o => o.OrderNumber).IsUnique(true);
            });

            // ---------- OrderDetail ----------
            modelBuilder.Entity<OrderDetail>(entity =>
            {
                entity.ToTable("OrderDetails");
                entity.HasKey(od => od.Id);

                entity.HasOne(od => od.Order)
                      .WithMany(o => o.OrderDetails)
                      .HasForeignKey(od => od.OrderId);

                entity.HasOne(od => od.Product)
                      .WithMany(p => p.OrderDetails)
                      .HasForeignKey(od => od.ProductId);
            });


            // ---------- Cart ----------
            modelBuilder.Entity<Cart>(entity =>
            {
                entity.ToTable("Carts");
                entity.HasKey(c => c.Id);
                entity.Property(c => c.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
                entity.HasIndex(c => c.UserId).IsUnique();
                entity.HasOne(c => c.User)
                      .WithMany()
                      .HasForeignKey(c => c.UserId)
                      .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(c => c.Status)
                      .WithMany() // Status class did not declare Cart navigation
                      .HasForeignKey(c => c.StatusId)
                      .OnDelete(DeleteBehavior.Restrict);

                entity.HasMany(c => c.CartItems)
                      .WithOne(ci => ci.Cart)
                      .HasForeignKey(ci => ci.CartId)
                      .OnDelete(DeleteBehavior.Cascade);
            });

            // ---------- CartItem ----------
            modelBuilder.Entity<CartItem>(entity =>
            {
                entity.ToTable("CartItems");
                entity.HasKey(ci => ci.Id);
                entity.Property(ci => ci.Quantity).IsRequired();
                entity.Property(ci => ci.UnitPrice).HasColumnType("decimal(18,2)");
                entity.HasIndex(ci => new { ci.CartId, ci.ProductId }).IsUnique();

                entity.HasOne(ci => ci.Product)
                      .WithMany()
                      .HasForeignKey(ci => ci.ProductId)
                      .OnDelete(DeleteBehavior.Restrict);
            });

            // ---------- Comment ----------
            modelBuilder.Entity<Comment>(entity =>
            {
                entity.ToTable("Comments");
                entity.HasKey(c => c.Id);
                entity.Property(c => c.Content).IsRequired().HasMaxLength(2000);
                entity.Property(c => c.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
                entity.HasIndex(c => new { c.UserId, c.ProductId }).IsUnique();
                entity.HasOne(c => c.User)
                      .WithMany()
                      .HasForeignKey(c => c.UserId)
                      .OnDelete(DeleteBehavior.Restrict);
                entity.HasOne(c => c.Product)
                      .WithMany()
                      .HasForeignKey(c => c.ProductId)
                      .OnDelete(DeleteBehavior.Restrict);
            });

            // ---------- Notification ----------
            modelBuilder.Entity<Notification>(entity =>
            {
                entity.ToTable("Notifications");
                entity.HasKey(n => n.Id);
                entity.Property(n => n.Code).HasMaxLength(100);
                entity.Property(n => n.Title).IsRequired().HasMaxLength(300);
                entity.Property(n => n.Message).IsRequired().HasMaxLength(4000);
                entity.Property(n => n.Type).HasMaxLength(100);
                entity.Property(n => n.CreatedAt).HasDefaultValueSql("GETUTCDATE()");

                // Add unique indexes for Code and Title
                entity.HasIndex(n => n.Code).IsUnique(true);
                entity.HasIndex(n => n.Title).IsUnique(true);
            });

            // ---------- AuditLog ----------
            modelBuilder.Entity<AuditLog>(entity =>
            {
                entity.ToTable("AuditLogs");
                entity.HasKey(a => a.Id);
                entity.Property(a => a.Action).IsRequired().HasMaxLength(200);
                entity.Property(a => a.TableName).IsRequired().HasMaxLength(200);
                entity.Property(a => a.OldValue).HasMaxLength(4000);
                entity.Property(a => a.NewValue).HasMaxLength(4000);
                entity.Property(a => a.Description).HasMaxLength(2000);
                entity.Property(a => a.IPAddress).HasMaxLength(100);
                entity.Property(a => a.CreatedAt).HasDefaultValueSql("GETUTCDATE()");

                entity.HasOne(a => a.User)
                      .WithMany()
                      .HasForeignKey(a => a.UserId)
                      .OnDelete(DeleteBehavior.SetNull);
            });
            modelBuilder.Entity<RolePermission>()
                .HasKey(rp => new { rp.RoleId, rp.PermissionId });

            modelBuilder.Entity<RolePermission>()
                .HasOne(rp => rp.Role)
                .WithMany(r => r.RolePermissions)
                .HasForeignKey(rp => rp.RoleId);

            modelBuilder.Entity<RolePermission>()
                .HasOne(rp => rp.Permission)
                .WithMany(p => p.RolePermissions)
                .HasForeignKey(rp => rp.PermissionId);

            modelBuilder.Entity<Status>().HasData(
                new Status { Id = 1, Code = "ACTIVE", Name = "Active", Description = "Active status" },
                new Status { Id = 2, Code = "INACTIVE", Name = "Inactive", Description = "Inactive status" },
                new Status { Id = 3, Code = "PAYMENT_SUCCESS", Name = "Thanh toán thành công", Description = "Đơn hàng đã thanh toán thành công" },
                new Status { Id = 4, Code = "PENDING_CONFIRMATION", Name = "Chờ xác nhận", Description = "Đơn hàng đang chờ xác nhận" },
                new Status { Id = 5, Code = "CONFIRMED", Name = "Xác nhận", Description = "Đơn hàng đã được xác nhận" },
                new Status { Id = 6, Code = "CANCELLED", Name = "Đã hủy", Description = "Đơn hàng đã bị hủy" }
            );
            modelBuilder.Entity<Role>().HasData(
                new Role { Id = 1, Code = "SUPER ADMIN", Name = "Super Admin" },
                new Role { Id = 2, Code = "ADMIN", Name = "Admin" },
                new Role { Id = 3, Code = "STAFF", Name = "Staff" },
                new Role { Id = 4, Code = "CUSTOMER", Name = "Customer" }
            );
            var passwordHelper = new PasswordHelper();
            var hasherPass = passwordHelper.HashPassword("12345678");
            modelBuilder.Entity<User>().HasData(new User
            {
                Id = 1,
                FullName = "Admin",
                Phone = "0345602265",
                Email = "admin@gmail.com",
                PasswordHash = hasherPass,
                RoleId = 1,
                StatusId = 1,
                CreatedAt = DateTime.Now,
            });
            modelBuilder.Entity<Permission>().HasData(
                // Product
                new Permission { Id = 10, Code = "PRODUCT_VIEW", Description = "View products" },
                new Permission { Id = 11, Code = "PRODUCT_CREATE", Description = "Create product" },
                new Permission { Id = 12, Code = "PRODUCT_UPDATE", Description = "Update product" },
                new Permission { Id = 13, Code = "PRODUCT_DELETE", Description = "Delete product" },
                new Permission { Id = 57, Code = "PRODUCT_SEARCH", Description = "Search products" },
                new Permission { Id = 58, Code = "PRODUCT_SUGGEST", Description = "Suggest product keywords" },
                new Permission { Id = 59, Code = "PRODUCT_STORE_QUANTITY_MANAGE", Description = "Manage product-store quantity" },

                // Promotion
                new Permission { Id = 14, Code = "PROMOTION_VIEW", Description = "View promotions" },
                new Permission { Id = 15, Code = "PROMOTION_CREATE", Description = "Create promotion" },
                new Permission { Id = 16, Code = "PROMOTION_UPDATE", Description = "Update promotion" },
                new Permission { Id = 17, Code = "PROMOTION_DELETE", Description = "Delete promotion" },

                // Brand
                new Permission { Id = 18, Code = "BRAND_VIEW", Description = "View brands" },
                new Permission { Id = 19, Code = "BRAND_CREATE", Description = "Create brand" },
                new Permission { Id = 20, Code = "BRAND_UPDATE", Description = "Update brand" },
                new Permission { Id = 21, Code = "BRAND_DELETE", Description = "Delete brand" },

                // Store
                new Permission { Id = 22, Code = "STORE_VIEW", Description = "View stores" },
                new Permission { Id = 23, Code = "STORE_CREATE", Description = "Create store" },
                new Permission { Id = 24, Code = "STORE_UPDATE", Description = "Update store" },
                new Permission { Id = 25, Code = "STORE_DELETE", Description = "Delete store" },

                // Supplier
                new Permission { Id = 26, Code = "SUPPLIER_VIEW", Description = "View suppliers" },
                new Permission { Id = 27, Code = "SUPPLIER_CREATE", Description = "Create supplier" },
                new Permission { Id = 28, Code = "SUPPLIER_UPDATE", Description = "Update supplier" },
                new Permission { Id = 29, Code = "SUPPLIER_DELETE", Description = "Delete supplier" },

                // Receipt
                new Permission { Id = 30, Code = "RECEIPT_VIEW", Description = "View receipts" },
                new Permission { Id = 31, Code = "RECEIPT_CREATE", Description = "Create receipt" },
                new Permission { Id = 32, Code = "RECEIPT_UPDATE", Description = "Update receipt" },
                new Permission { Id = 33, Code = "RECEIPT_DELETE", Description = "Delete receipt" },

                // Order
                new Permission { Id = 34, Code = "ORDER_VIEW", Description = "View orders" },
                new Permission { Id = 35, Code = "ORDER_CREATE", Description = "Create order" },
                new Permission { Id = 36, Code = "ORDER_UPDATE", Description = "Update order" },
                new Permission { Id = 37, Code = "ORDER_DELETE", Description = "Delete order" },
                new Permission { Id = 60, Code = "ORDER_MANAGE_DETAILS", Description = "Manage order details/status" },

                // Notification
                new Permission { Id = 38, Code = "NOTIFICATION_VIEW", Description = "View notifications" },
                new Permission { Id = 39, Code = "NOTIFICATION_CREATE", Description = "Create notification" },
                new Permission { Id = 40, Code = "NOTIFICATION_DELETE", Description = "Delete notification" },

                // Comment
                new Permission { Id = 41, Code = "COMMENT_VIEW", Description = "View comments" },
                new Permission { Id = 42, Code = "COMMENT_CREATE", Description = "Create comment" },
                new Permission { Id = 43, Code = "COMMENT_UPDATE", Description = "Update comment" },
                new Permission { Id = 44, Code = "COMMENT_DELETE", Description = "Delete comment" },

                // Cart
                new Permission { Id = 45, Code = "CART_VIEW", Description = "View cart" },
                new Permission { Id = 46, Code = "CART_CREATE", Description = "Create/Add to cart" },
                new Permission { Id = 47, Code = "CART_UPDATE", Description = "Update cart item" },
                new Permission { Id = 48, Code = "CART_DELETE", Description = "Remove from cart / clear cart" },

                // User management
                new Permission { Id = 49, Code = "USER_VIEW", Description = "View users" },
                new Permission { Id = 50, Code = "USER_CREATE", Description = "Create user" },
                new Permission { Id = 51, Code = "USER_UPDATE", Description = "Update user" },
                new Permission { Id = 52, Code = "USER_DELETE", Description = "Delete user" },

                // Roles & permissions / admin features
                new Permission { Id = 53, Code = "ROLE_MANAGE", Description = "Manage roles" },
                new Permission { Id = 54, Code = "PERMISSION_MANAGE", Description = "Manage permissions" },

                // Dashboard & Audit
                new Permission { Id = 55, Code = "DASHBOARD_VIEW", Description = "View dashboard" },
                new Permission { Id = 56, Code = "AUDIT_VIEW", Description = "View audit logs" }
            );

            // Seed RolePermission: map permissions to roles
            // - Super Admin (Id = 1) -> all permissions
            // - Admin (Id = 2) -> most management permissions (except PERMISSION_MANAGE)
            // - Staff (Id = 3) -> view/create/update for operational resources, limited deletes
            // - Customer (Id = 4) -> view products, comment create, cart & order create/view own
            modelBuilder.Entity<RolePermission>().HasData(
                // Super Admin (1) - all
                new RolePermission { RoleId = 1, PermissionId = 10 },
                new RolePermission { RoleId = 1, PermissionId = 11 },
                new RolePermission { RoleId = 1, PermissionId = 12 },
                new RolePermission { RoleId = 1, PermissionId = 13 },
                new RolePermission { RoleId = 1, PermissionId = 57 },
                new RolePermission { RoleId = 1, PermissionId = 58 },
                new RolePermission { RoleId = 1, PermissionId = 59 },

                new RolePermission { RoleId = 1, PermissionId = 14 },
                new RolePermission { RoleId = 1, PermissionId = 15 },
                new RolePermission { RoleId = 1, PermissionId = 16 },
                new RolePermission { RoleId = 1, PermissionId = 17 },

                new RolePermission { RoleId = 1, PermissionId = 18 },
                new RolePermission { RoleId = 1, PermissionId = 19 },
                new RolePermission { RoleId = 1, PermissionId = 20 },
                new RolePermission { RoleId = 1, PermissionId = 21 },

                new RolePermission { RoleId = 1, PermissionId = 22 },
                new RolePermission { RoleId = 1, PermissionId = 23 },
                new RolePermission { RoleId = 1, PermissionId = 24 },
                new RolePermission { RoleId = 1, PermissionId = 25 },

                new RolePermission { RoleId = 1, PermissionId = 26 },
                new RolePermission { RoleId = 1, PermissionId = 27 },
                new RolePermission { RoleId = 1, PermissionId = 28 },
                new RolePermission { RoleId = 1, PermissionId = 29 },

                new RolePermission { RoleId = 1, PermissionId = 30 },
                new RolePermission { RoleId = 1, PermissionId = 31 },
                new RolePermission { RoleId = 1, PermissionId = 32 },
                new RolePermission { RoleId = 1, PermissionId = 33 },

                new RolePermission { RoleId = 1, PermissionId = 34 },
                new RolePermission { RoleId = 1, PermissionId = 35 },
                new RolePermission { RoleId = 1, PermissionId = 36 },
                new RolePermission { RoleId = 1, PermissionId = 37 },
                new RolePermission { RoleId = 1, PermissionId = 60 },

                new RolePermission { RoleId = 1, PermissionId = 38 },
                new RolePermission { RoleId = 1, PermissionId = 39 },
                new RolePermission { RoleId = 1, PermissionId = 40 },

                new RolePermission { RoleId = 1, PermissionId = 41 },
                new RolePermission { RoleId = 1, PermissionId = 42 },
                new RolePermission { RoleId = 1, PermissionId = 43 },
                new RolePermission { RoleId = 1, PermissionId = 44 },

                new RolePermission { RoleId = 1, PermissionId = 45 },
                new RolePermission { RoleId = 1, PermissionId = 46 },
                new RolePermission { RoleId = 1, PermissionId = 47 },
                new RolePermission { RoleId = 1, PermissionId = 48 },

                new RolePermission { RoleId = 1, PermissionId = 49 },
                new RolePermission { RoleId = 1, PermissionId = 50 },
                new RolePermission { RoleId = 1, PermissionId = 51 },
                new RolePermission { RoleId = 1, PermissionId = 52 },

                new RolePermission { RoleId = 1, PermissionId = 53 },
                new RolePermission { RoleId = 1, PermissionId = 54 },
                new RolePermission { RoleId = 1, PermissionId = 55 },
                new RolePermission { RoleId = 1, PermissionId = 56 },

                // Admin (2) - management for domain areas, but not PERMISSION_MANAGE
                new RolePermission { RoleId = 2, PermissionId = 10 },
                new RolePermission { RoleId = 2, PermissionId = 11 },
                new RolePermission { RoleId = 2, PermissionId = 12 },
                new RolePermission { RoleId = 2, PermissionId = 13 },
                new RolePermission { RoleId = 2, PermissionId = 57 },
                new RolePermission { RoleId = 2, PermissionId = 58 },
                new RolePermission { RoleId = 2, PermissionId = 59 },

                new RolePermission { RoleId = 2, PermissionId = 14 },
                new RolePermission { RoleId = 2, PermissionId = 15 },
                new RolePermission { RoleId = 2, PermissionId = 16 },
                new RolePermission { RoleId = 2, PermissionId = 17 },

                new RolePermission { RoleId = 2, PermissionId = 18 },
                new RolePermission { RoleId = 2, PermissionId = 19 },
                new RolePermission { RoleId = 2, PermissionId = 20 },
                new RolePermission { RoleId = 2, PermissionId = 21 },

                new RolePermission { RoleId = 2, PermissionId = 22 },
                new RolePermission { RoleId = 2, PermissionId = 23 },
                new RolePermission { RoleId = 2, PermissionId = 24 },
                new RolePermission { RoleId = 2, PermissionId = 25 },

                new RolePermission { RoleId = 2, PermissionId = 26 },
                new RolePermission { RoleId = 2, PermissionId = 27 },
                new RolePermission { RoleId = 2, PermissionId = 28 },
                new RolePermission { RoleId = 2, PermissionId = 29 },

                new RolePermission { RoleId = 2, PermissionId = 30 },
                new RolePermission { RoleId = 2, PermissionId = 31 },
                new RolePermission { RoleId = 2, PermissionId = 32 },
                new RolePermission { RoleId = 2, PermissionId = 33 },

                new RolePermission { RoleId = 2, PermissionId = 34 },
                new RolePermission { RoleId = 2, PermissionId = 35 },
                new RolePermission { RoleId = 2, PermissionId = 36 },
                new RolePermission { RoleId = 2, PermissionId = 37 },
                new RolePermission { RoleId = 2, PermissionId = 60 },

                new RolePermission { RoleId = 2, PermissionId = 38 },
                new RolePermission { RoleId = 2, PermissionId = 39 },
                new RolePermission { RoleId = 2, PermissionId = 40 },

                new RolePermission { RoleId = 2, PermissionId = 41 },
                new RolePermission { RoleId = 2, PermissionId = 42 },
                new RolePermission { RoleId = 2, PermissionId = 43 },
                new RolePermission { RoleId = 2, PermissionId = 44 },

                new RolePermission { RoleId = 2, PermissionId = 45 },
                new RolePermission { RoleId = 2, PermissionId = 46 },
                new RolePermission { RoleId = 2, PermissionId = 47 },
                new RolePermission { RoleId = 2, PermissionId = 48 },

                new RolePermission { RoleId = 2, PermissionId = 49 },
                new RolePermission { RoleId = 2, PermissionId = 50 },
                new RolePermission { RoleId = 2, PermissionId = 51 },
                new RolePermission { RoleId = 2, PermissionId = 52 },

                new RolePermission { RoleId = 2, PermissionId = 53 },
                // Admin intentionally not granted PermissionId = 54 (PERMISSION_MANAGE) here
                new RolePermission { RoleId = 2, PermissionId = 55 },

                // Staff (3) - operational: view and basic create/update, limited deletes
                new RolePermission { RoleId = 3, PermissionId = 10 },
                new RolePermission { RoleId = 3, PermissionId = 57 },
                new RolePermission { RoleId = 3, PermissionId = 58 },
                new RolePermission { RoleId = 3, PermissionId = 18 },
                new RolePermission { RoleId = 3, PermissionId = 22 },
                new RolePermission { RoleId = 3, PermissionId = 26 },
                new RolePermission { RoleId = 3, PermissionId = 34 },
                new RolePermission { RoleId = 3, PermissionId = 35 }, //create order
                new RolePermission { RoleId = 3, PermissionId = 36 }, // update order
                new RolePermission { RoleId = 3, PermissionId = 60 }, // manage order details/status
                new RolePermission { RoleId = 3, PermissionId = 41 },
                new RolePermission { RoleId = 3, PermissionId = 42 }, // create comment
                new RolePermission { RoleId = 3, PermissionId = 43 }, // update comment
                new RolePermission { RoleId = 3, PermissionId = 45 }, // view cart (admin-staff may view)
                new RolePermission { RoleId = 3, PermissionId = 55 }, // dashboard view

                // Customer (4) - end-user: view products, comment, cart, create orders
                new RolePermission { RoleId = 4, PermissionId = 10 }, // product view
                new RolePermission { RoleId = 4, PermissionId = 42 }, // comment create
                new RolePermission { RoleId = 4, PermissionId = 45 }, // cart view
                new RolePermission { RoleId = 4, PermissionId = 46 }, // cart create (add)
                new RolePermission { RoleId = 4, PermissionId = 47 }, // cart update
                new RolePermission { RoleId = 4, PermissionId = 48 }, // cart delete
                new RolePermission { RoleId = 4, PermissionId = 35 }, // order create
                new RolePermission { RoleId = 4, PermissionId = 34 }  // order view (own)
            );

        }
    }
}
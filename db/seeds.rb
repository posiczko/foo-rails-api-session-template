User.create!(
  email: "admin@example.com",
  first_name: "Admin",
  last_name: "User",
  admin: true
)

User.crate!(
  email: "user@example.com",
  first_name: "Regular",
  last_name: "User",
)

User.create!(
  username: "admin@example.com",
  first_name: "Admin",
  last_name: "User",
  password: BCrypt::Password.create('secret'),
  admin: true
)

User.create!(
  username: "user@example.com",
  first_name: "Regular",
  last_name: "User",
  password: BCrypt::Password.create('secret'),
)

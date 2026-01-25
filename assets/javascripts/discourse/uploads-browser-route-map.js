export default function () {
  this.route("admin", function () {
    // This defines the internal name 'admin.uploads'
    this.route("uploads", { path: "/uploads" });
  });
}

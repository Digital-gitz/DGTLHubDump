import qrcode
# URL of your GitHub repository
repo_url = "https://github.com/Digital-gitz/DGTLHubDump"
# Generate QR code
qr = qrcode.QRCode(
   version=1,
   error_correction=qrcode.constants.ERROR_CORRECT_L,
   box_size=10,
   border=4,
)
qr.add_data(repo_url)
qr.make(fit=True)
# Create an image from the QR Code instance
img = qr.make_image(fill_color="black", back_color="white")
# Save the image
img.save("github_repo_qr.png")
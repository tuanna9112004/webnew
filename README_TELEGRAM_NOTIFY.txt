HUONG DAN TICH HOP THONG BAO TELEGRAM
===================================

1. Mo bot tren dien thoai va bam Start.
2. Tao token moi trong @BotFather neu token cu da lo.
3. Lay chat_id bang trinh duyet:
   https://api.telegram.org/bot<YOUR_NEW_TOKEN>/getUpdates
   Sau khi bam Start, tim "chat":{"id":...}
4. Vao /admin/settings.php va nhap:
   - Username bot Telegram (khong bat buoc)
   - Bot Token Telegram
   - Chat ID Telegram
   - Bat checkbox "Bat thong bao Telegram cho don da coc / da thanh toan"
5. Luu thiet lap.

He thong se tu dong gui Telegram khi:
- Webhook SePay xac nhan don da dat coc
- Webhook SePay xac nhan don da thanh toan
- Admin tu doi trang thai thanh toan sang da_dat_coc / da_thanh_toan

Ghi chu:
- He thong tu tao bang telegram_notification_logs neu chua co.
- Moi don chi gui 1 lan cho tung moc: da_dat_coc, da_thanh_toan.

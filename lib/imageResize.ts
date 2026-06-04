// 在瀏覽器把 File 縮放壓成 base64（去掉 data: 前綴），長邊上限 1600px
export async function fileToCompressedBase64(
  file: File,
  maxEdge = 1600,
  quality = 0.82,
): Promise<{ type: string; data: string }> {
  const bitmap = await createImageBitmap(file);
  const scale = Math.min(1, maxEdge / Math.max(bitmap.width, bitmap.height));
  const w = Math.round(bitmap.width * scale);
  const h = Math.round(bitmap.height * scale);
  const canvas = document.createElement("canvas");
  canvas.width = w;
  canvas.height = h;
  const ctx = canvas.getContext("2d")!;
  ctx.drawImage(bitmap, 0, 0, w, h);
  const dataUrl = canvas.toDataURL("image/jpeg", quality);
  return { type: "image/jpeg", data: dataUrl.split(",")[1] };
}

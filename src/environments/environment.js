export const environment = {
  production: true,
  api_key_imgbb: "5e8520a4a581822f7aef6ae42d2e407b",
  // Vite exposes env vars prefixed with VITE_ at build time via import.meta.env
  serverBasePath:
    (typeof import.meta !== "undefined" &&
      import.meta.env &&
      import.meta.env.VITE_SERVER_BASE_PATH) ||
    "https://upc-pre-20610-1asi0657-8517-replink.onrender.com/api/v1",
};

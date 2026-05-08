# ================ 基础镜像 ================
FROM codercom/code-server:latest

# ================ 切换到 root，获取安装权限 ================
USER root

# ================ 1. 安装 Node.js 24（LTS 版本） ================
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# ================ 2.1 安装 Claude Code CLI（插件运行的基础） ================
RUN npm install -g @anthropic-ai/claude-code

# ================ 2.2 安装 cc-connect（AI Agent 消息平台桥接） ================
RUN npm install -g cc-connect

# ================ 2.3 安装 cc-weixin Agent 微信平台桥接） ================
RUN npm install -g cc-weixin

# ================ 3. 预装 Claude Code VS Code 插件 ================
# code-server 默认使用 Open VSX Registry，需要切换到官方 VS Code Marketplace
ENV EXTENSIONS_GALLERY='{"serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery", "itemUrl": "https://marketplace.visualstudio.com/items"}'

# 安装到 /opt/extensions（避开 /home/coder，不会被 volume 挂载遮盖）
RUN mkdir -p /opt/code-server-extensions \
    && code-server --install-extension anthropic.claude-code --extensions-dir /opt/code-server-extensions \
    && chown -R 1000:1000 /opt/code-server-extensions

# ================ 4. 启动脚本：附加 --extensions-dir 参数 ================
RUN echo '#!/bin/bash\nexec code-server --extensions-dir /opt/code-server-extensions "$@"' > /opt/entrypoint.sh \
    && chmod +x /opt/entrypoint.sh
ENTRYPOINT ["/opt/entrypoint.sh"]

# ================ 恢复为普通用户，保障安全 ================
USER 1000
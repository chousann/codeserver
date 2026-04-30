# ================ 基础镜像 ================
FROM codercom/code-server:latest

# ================ 切换到 root，获取安装权限 ================
USER root

# ================ 1. 安装 Node.js 24（LTS 版本） ================
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# ================ 2. 安装 Claude Code CLI（插件运行的基础） ================
RUN npm install -g @anthropic-ai/claude-code

# ================ 2.5 安装 cc-connect（AI Agent 消息平台桥接） ================
RUN npm install -g cc-connect

# ================ 3. 预装 Claude Code VS Code 插件 ================
# code-server 默认使用 Open VSX Registry，需要切换到官方 VS Code Marketplace
ENV EXTENSIONS_GALLERY='{"serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery", "itemUrl": "https://marketplace.visualstudio.com/items"}'

# 安装到当前用户的默认扩展目录
RUN code-server --install-extension anthropic.claude-code || echo ">>> EXTENSION INSTALL FAILED <<<"

# ================ 普通用户 ================
# RUN mkdir -p /home/coder/.local/share/code-server/extensions \
#     && code-server --install-extension anthropic.claude-code --extensions-dir /home/coder/.local/share/code-server/extensions \
#     && chown -R 1000:1000 /home/coder/.local/share/code-server/extensions \
#     || echo ">>> EXTENSION INSTALL FAILED <<<"

# ================ 4. (可选) 安装其他常用插件 ================
# 可以通过以下方式安装其他插件：
# RUN code-server --install-extension <extension-id>

# ================ 恢复为普通用户，保障安全 ================
# USER 1000  临时 安全风险
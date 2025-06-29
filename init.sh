#!/bin/bash

echo "Gitpod init.sh 스크립트 시작..."

# 1. SSH 키를 저장할 디렉토리 생성 (없으면)
mkdir -p ~/.ssh

# 2. SSH 키가 이미 존재하는지 확인 (Gitpod 재시작 시 이미 생성된 키가 있을 수 있음)
if [ ! -f ~/.ssh/id_rsa ]; then
  echo "SSH 키를 생성합니다..."
  ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""

  echo "생성된 SSH 공개 키를 GitHub에 등록합니다..."
  curl -X POST -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    --data "{\"title\":\"gitpod-$(hostname)-$(date +%s)\",\"key\":\"$(cat ~/.ssh/id_rsa.pub)\"}" \
    https://api.github.com/user/keys

  echo "SSH 키 생성 및 GitHub 등록 완료."
else
  echo "SSH 키가 이미 존재합니다. 기존 키를 재사용합니다."
fi

# 3. GitHub 호스트를 known_hosts에 추가 (SSH 접속 시 경고 방지)
if ! grep -q "github.com" ~/.ssh/known_hosts; then
  echo "github.com을 known_hosts에 추가합니다..."
  ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null
fi

# 4. SSH 에이전트 시작 및 키 추가 (선택 사항이지만 권장)
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

echo "Git 환경 설정 완료."
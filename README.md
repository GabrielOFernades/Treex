# TREEX — Árvore de Diretórios Estendida (v5.4)

O **TREEX** é um script `.bat` para Windows que gera uma visualização em árvore de diretórios, semelhante ao comando `tree`, porém com **filtros avançados**, **controle de profundidade**, **inclusão/exclusão por padrão**, e **contagem global de arquivos e pastas**.

Ele é especialmente útil para auditoria de estruturas de pastas grandes, busca visual por tipos específicos de arquivos (ex: PDFs), ou documentação rápida de projetos.

---

## 📌 Principais Funcionalidades

- Exibe árvore hierárquica de diretórios e arquivos
- Limita profundidade máxima da árvore
- Mostra apenas diretórios ou apenas arquivos
- Filtra por padrão (`*.pdf`, `*.txt`, etc.)
- Exibe **somente as pastas relevantes** quando usa `-P`
- Exclui nomes por padrão (`node_modules`, `bin`, etc.)
- Inclui ou ignora arquivos/pastas ocultos
- Mostra total global de diretórios e arquivos ao final

---

## 📦 Instalação

1. Salve o arquivo como:

```text
treex.bat
```

2. Coloque o arquivo em um diretório fixo, por exemplo:

```text
C:\tools\treex\treex.bat
```

3. **Adicione esse diretório ao PATH do Windows** (obrigatório para usar de qualquer lugar).

### ➕ Como adicionar ao PATH no Windows

1. Pressione **Win + R**, digite `sysdm.cpl` e pressione Enter
2. Aba **Avançado** → **Variáveis de Ambiente**
3. Em **Variáveis do sistema**, selecione `Path` → **Editar**
4. Clique em **Novo** e adicione:

```text
C:\tools\treex
```

5. Confirme tudo e **abra um novo Prompt de Comando**

Teste:

```bat
treex -h
```

---

## ▶️ Uso Básico

```bat
treex [OPÇÕES] [DIRETÓRIO]
```

- Se nenhum diretório for informado, o diretório atual (`.`) será usado

Exemplo simples:

```bat
treex
```

---

## ⚙️ Opções Disponíveis

| Opção | Descrição |
|-----|----------|
| `-d` | Mostra **somente diretórios** |
| `-f` | Mostra **somente arquivos** |
| `-a` | Inclui arquivos e pastas ocultos |
| `-L <n>` | Define profundidade máxima |
| `-P <padrão>` | Mostra apenas arquivos que correspondem ao padrão e **pastas relevantes** |
| `-I <padrão>` | Exclui arquivos ou pastas que contenham o padrão |
| `-h`, `help`, `/?` | Mostra ajuda |

---

## 🔍 Exemplos de Uso

### 1️⃣ Árvore completa do diretório atual

```bat
treex
```

---

### 2️⃣ Listar somente diretórios

```bat
treex -d
```

---

### 3️⃣ Listar somente arquivos

```bat
treex -f C:\Projetos
```

---

### 4️⃣ Limitar profundidade da árvore

```bat
treex -L 2
```

---

### 5️⃣ Mostrar apenas PDFs (pastas relevantes)

```bat
treex -P *.pdf
```

📌 **Comportamento importante**:
- Apenas arquivos `.pdf` serão exibidos
- Apenas pastas que levam até algum `.pdf` aparecem na árvore

---

### 6️⃣ PDFs até 3 níveis de profundidade

```bat
treex -P *.pdf -L 3 C:\Documentos
```

---

### 7️⃣ Excluir pastas ou arquivos por nome

```bat
treex -I node_modules
```

Ou múltiplos casos (parcial):

```bat
treex -I .git
```

---

### 8️⃣ Combinação avançada

```bat
treex -P *.log -I backup -L 4 -f C:\Servidores
```

✔ Mostra somente arquivos `.log`  
✔ Ignora qualquer coisa com `backup` no nome  
✔ Limita a 4 níveis  
✔ Apenas arquivos

---

## 📊 Contadores Globais

Ao final da execução, o TREEX exibe:

- Total de diretórios
- Total de arquivos

Exemplo:

```text
Total: 18 diretorios, 42 arquivos
```

---

## 🧠 Observações Técnicas

- O script usa `chcp 65001` para suporte a UTF-8 (caracteres de árvore)
- Compatível com **Prompt de Comando (cmd.exe)**
- Não depende de PowerShell
- Funciona em Windows 10 e 11

---

## 🛠 Dicas

- Use `-P` sempre que quiser **reduzir ruído visual**
- Combine `-P` com `-L` para buscas rápidas em estruturas grandes
- Ideal para documentação de projetos e auditorias

---

## 📄 Licença

Uso livre para fins pessoais e profissionais.

---

✨ Bom uso!


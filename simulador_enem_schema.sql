CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE public.perfis (
    id              UUID        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    nome_completo   TEXT        NOT NULL,
    papel           VARCHAR(20) NOT NULL DEFAULT 'aluno'
                        CHECK (papel IN ('aluno', 'admin_escolar', 'admin_global')),
    criado_em       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.escolas (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    nome        TEXT        NOT NULL,
    cnpj        VARCHAR(18) NOT NULL UNIQUE,
    admin_id    UUID        NOT NULL REFERENCES public.perfis(id) ON DELETE RESTRICT,
    criado_em   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.matriculas (
    id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    aluno_id       UUID        NOT NULL REFERENCES public.perfis(id) ON DELETE CASCADE,
    escola_id      UUID        NOT NULL REFERENCES public.escolas(id) ON DELETE CASCADE,
    matriculado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_matricula UNIQUE (aluno_id, escola_id)
);

CREATE TABLE public.questoes (
    id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    numero_ordem INT         NOT NULL,
    enunciado    JSONB       NOT NULL,
    alternativas JSONB       NOT NULL,
    criado_em    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.sessoes_simulado (
    id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    aluno_id       UUID        NOT NULL REFERENCES public.perfis(id) ON DELETE CASCADE,
    iniciado_em    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    finalizado_em  TIMESTAMPTZ,
    status         VARCHAR(20) NOT NULL DEFAULT 'em_andamento'
                       CHECK (status IN ('em_andamento', 'concluida')),
    total_questoes INT         NOT NULL DEFAULT 0 CHECK (total_questoes >= 0),
    total_acertos  INT         NOT NULL DEFAULT 0 CHECK (total_acertos >= 0),
    CONSTRAINT chk_acertos_lte_total CHECK (total_acertos <= total_questoes)
);

CREATE TABLE public.respostas (
    id                    UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    sessao_id             UUID        NOT NULL REFERENCES public.sessoes_simulado(id) ON DELETE CASCADE,
    questao_id            UUID        NOT NULL REFERENCES public.questoes(id) ON DELETE CASCADE,
    alternativa_escolhida INT         NOT NULL CHECK (alternativa_escolhida >= 0),
    esta_correta          BOOLEAN     NOT NULL,
    respondido_em         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_resposta_por_sessao UNIQUE (sessao_id, questao_id)
);

CREATE INDEX idx_matriculas_aluno  ON public.matriculas(aluno_id);
CREATE INDEX idx_matriculas_escola ON public.matriculas(escola_id);
CREATE INDEX idx_sessoes_aluno     ON public.sessoes_simulado(aluno_id);
CREATE INDEX idx_respostas_sessao  ON public.respostas(sessao_id);
CREATE INDEX idx_respostas_questao ON public.respostas(questao_id);
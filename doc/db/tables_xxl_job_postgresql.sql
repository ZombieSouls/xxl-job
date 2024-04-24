-- #
-- # XXL-JOB v2.4.2-SNAPSHOT
-- # Copyright (c) 2015-present, xuxueli.
--
-- # 创建一个 xxl_job 用户，密码：123456
CREATE USER xxl_job WITH PASSWORD '123456';
-- # 创建一个 xxl_job 数据库，属于 xxl_job 用户
CREATE DATABASE xxl_job OWNER xxl_job;
-- # 创建一个 xxl_job SCHEMA，属于 xxl_job 用户
CREATE SCHEMA xxl_job.xxl_job AUTHORIZATION xxl_job;
-- # 将 xxl_job 数据库授权给 xxl_job 用户
GRANT ALL PRIVILEGES ON DATABASE xxl_job TO xxl_job;

CREATE TABLE xxl_job_info
(
    id                        BIGSERIAL PRIMARY KEY NOT NULL,
    job_group                 INT                   NOT NULL,
    job_desc                  VARCHAR(255)          NOT NULL,
    add_time                  TIMESTAMP,
    update_time               TIMESTAMP,
    author                    VARCHAR(64)                    DEFAULT NULL,
    alarm_email               VARCHAR(255)                   DEFAULT NULL,
    schedule_type             VARCHAR(50)           NOT NULL DEFAULT 'NONE',
    schedule_conf             VARCHAR(128)                   DEFAULT NULL,
    misfire_strategy          VARCHAR(50)           NOT NULL DEFAULT 'DO_NOTHING',
    executor_route_strategy   VARCHAR(50)                    DEFAULT NULL,
    executor_handler          VARCHAR(255)                   DEFAULT NULL,
    executor_param            VARCHAR(512)                   DEFAULT NULL,
    executor_block_strategy   VARCHAR(50)                    DEFAULT NULL,
    executor_timeout          INT                   NOT NULL DEFAULT 0,
    executor_fail_retry_count INT                   NOT NULL DEFAULT 0,
    glue_type                 VARCHAR(50)           NOT NULL,
    glue_source               TEXT,
    glue_remark               VARCHAR(128)                   DEFAULT NULL,
    glue_updatetime           TIMESTAMP,
    child_jobid               VARCHAR(255)                   DEFAULT NULL,
    trigger_status            INT                   NOT NULL DEFAULT 0,
    trigger_last_time         BIGINT                NOT NULL DEFAULT 0,
    trigger_next_time         BIGINT                NOT NULL DEFAULT 0
);

COMMENT ON TABLE xxl_job_info IS '调度扩展信息表：用于保存xxl-job调度任务的扩展信息，如任务分组、任务名、机器地址、执行器、执行入参和报警邮件等等';

COMMENT ON COLUMN xxl_job_info.job_group IS '执行器主键ID';
COMMENT ON COLUMN xxl_job_info.author IS '作者';
COMMENT ON COLUMN xxl_job_info.alarm_email IS '报警邮件';
COMMENT ON COLUMN xxl_job_info.schedule_type IS '调度类型';
COMMENT ON COLUMN xxl_job_info.schedule_conf IS '调度配置，值含义取决于调度类型';
COMMENT ON COLUMN xxl_job_info.misfire_strategy IS '调度过期策略';
COMMENT ON COLUMN xxl_job_info.executor_route_strategy IS '执行器路由策略';
COMMENT ON COLUMN xxl_job_info.executor_handler IS '执行器任务handler';
COMMENT ON COLUMN xxl_job_info.executor_param IS '执行器任务参数';
COMMENT ON COLUMN xxl_job_info.executor_block_strategy IS '阻塞处理策略';
COMMENT ON COLUMN xxl_job_info.executor_timeout IS '任务执行超时时间，单位秒';
COMMENT ON COLUMN xxl_job_info.executor_fail_retry_count IS '失败重试次数';
COMMENT ON COLUMN xxl_job_info.glue_type IS 'GLUE类型';
COMMENT ON COLUMN xxl_job_info.glue_source IS 'GLUE源代码';
COMMENT ON COLUMN xxl_job_info.glue_remark IS 'GLUE备注';
COMMENT ON COLUMN xxl_job_info.glue_updatetime IS 'GLUE更新时间';
COMMENT ON COLUMN xxl_job_info.child_jobid IS '子任务ID，多个逗号分隔';
COMMENT ON COLUMN xxl_job_info.trigger_status IS '调度状态：0-停止，1-运行';
COMMENT ON COLUMN xxl_job_info.trigger_last_time IS '上次调度时间';
COMMENT ON COLUMN xxl_job_info.trigger_next_time IS '下次调度时间';

CREATE TABLE xxl_job_log
(
    id                        BIGSERIAL PRIMARY KEY NOT NULL,
    job_group                 INT                   NOT NULL,
    job_id                    INT                   NOT NULL,
    executor_address          VARCHAR(255)                   DEFAULT NULL,
    executor_handler          VARCHAR(255)                   DEFAULT NULL,
    executor_param            VARCHAR(512)                   DEFAULT NULL,
    executor_sharding_param   VARCHAR(20)                    DEFAULT NULL,
    executor_fail_retry_count INT                   NOT NULL DEFAULT 0,
    trigger_time              TIMESTAMP,
    trigger_code              INT                   NOT NULL,
    trigger_msg               TEXT,
    handle_time               TIMESTAMP,
    handle_code               INT                   NOT NULL,
    handle_msg                TEXT,
    alarm_status              INT                   NOT NULL DEFAULT 0
);

COMMENT ON TABLE xxl_job_log IS '调度日志表：用于保存xxl-job调度任务的历史信息，如调度结果、执行结果、调度入参、调度机器和执行器等等';
COMMENT ON COLUMN xxl_job_log.job_group IS '执行器主键ID';
COMMENT ON COLUMN xxl_job_log.job_id IS '任务，主键ID';
COMMENT ON COLUMN xxl_job_log.executor_address IS '执行器地址，本次执行的地址';
COMMENT ON COLUMN xxl_job_log.executor_handler IS '执行器任务handler';
COMMENT ON COLUMN xxl_job_log.executor_param IS '执行器任务参数';
COMMENT ON COLUMN xxl_job_log.executor_sharding_param IS '执行器任务分片参数，格式如 1/2';
COMMENT ON COLUMN xxl_job_log.executor_fail_retry_count IS '失败重试次数';
COMMENT ON COLUMN xxl_job_log.trigger_time IS '调度-时间';
COMMENT ON COLUMN xxl_job_log.trigger_code IS '调度-结果';
COMMENT ON COLUMN xxl_job_log.trigger_msg IS '调度-日志';
COMMENT ON COLUMN xxl_job_log.handle_time IS '执行-时间';
COMMENT ON COLUMN xxl_job_log.handle_code IS '执行-状态';
COMMENT ON COLUMN xxl_job_log.handle_msg IS '执行-日志';
COMMENT ON COLUMN xxl_job_log.alarm_status IS '告警状态：0-默认、1-无需告警、2-告警成功、3-告警失败';

CREATE INDEX idx_trigger_time ON xxl_job_log USING btree (trigger_time);
CREATE INDEX idx_handle_code ON xxl_job_log USING btree (handle_code);

CREATE TABLE xxl_job_log_report
(
    id            BIGSERIAL PRIMARY KEY NOT NULL,
    trigger_day   TIMESTAMP,
    running_count INT                   NOT NULL DEFAULT 0,
    suc_count     INT                   NOT NULL DEFAULT 0,
    fail_count    INT                   NOT NULL DEFAULT 0,
    update_time   TIMESTAMP,
    CONSTRAINT uk_trigger_day UNIQUE (trigger_day)
);

COMMENT ON TABLE xxl_job_log_report IS '调度日志报表：用户存储xxl-job任务调度日志的报表，调度中心报表功能页面会用到';

COMMENT ON COLUMN xxl_job_log_report.trigger_day IS '调度-时间';
COMMENT ON COLUMN xxl_job_log_report.running_count IS '运行中-日志数量';
COMMENT ON COLUMN xxl_job_log_report.suc_count IS '执行成功-日志数量';
COMMENT ON COLUMN xxl_job_log_report.fail_count IS '执行失败-日志数量';

CREATE TABLE xxl_job_logglue
(
    id          BIGSERIAL PRIMARY KEY NOT NULL,
    job_id      INT                   NOT NULL,
    glue_type   VARCHAR(50) DEFAULT NULL,
    glue_source TEXT,
    glue_remark VARCHAR(128)          NOT NULL,
    add_time    TIMESTAMP,
    update_time TIMESTAMP
);

COMMENT ON TABLE xxl_job_logglue IS '任务GLUE日志：用于保存GLUE更新历史，用于支持GLUE的版本回溯功能';

COMMENT ON COLUMN xxl_job_logglue.job_id IS '任务，主键ID';
COMMENT ON COLUMN xxl_job_logglue.glue_type IS 'GLUE类型';
COMMENT ON COLUMN xxl_job_logglue.glue_source IS 'GLUE源代码';
COMMENT ON COLUMN xxl_job_logglue.glue_remark IS 'GLUE备注';
CREATE TABLE xxl_job_registry
(
    id             BIGSERIAL PRIMARY KEY NOT NULL,
    registry_group VARCHAR(50)           NOT NULL,
    registry_key   VARCHAR(255)          NOT NULL,
    registry_value VARCHAR(255)          NOT NULL,
    update_time    TIMESTAMP
);

COMMENT ON TABLE xxl_job_registry IS '执行器注册表，维护在线的执行器和调度中心机器地址信息';

CREATE INDEX idx_registry_group_registry_key_registry_value ON xxl_job_registry USING btree (registry_group, registry_key, registry_value);

CREATE TABLE xxl_job_group
(
    id           BIGSERIAL PRIMARY KEY NOT NULL,
    app_name     VARCHAR(64)           NOT NULL,
    title        VARCHAR(12)           NOT NULL,
    address_type INT                   NOT NULL DEFAULT 0,
    address_list TEXT,
    update_time  TIMESTAMP
);

COMMENT ON TABLE xxl_job_group IS '执行器信息表：维护任务执行器信息';
COMMENT ON COLUMN xxl_job_group.app_name IS '执行器AppName';
COMMENT ON COLUMN xxl_job_group.title IS '执行器名称';
COMMENT ON COLUMN xxl_job_group.address_type IS '执行器地址类型：0=自动注册、1=手动录入';
COMMENT ON COLUMN xxl_job_group.address_list IS '执行器地址列表，多地址逗号分隔';

CREATE TABLE xxl_job_user
(
    id         BIGSERIAL PRIMARY KEY NOT NULL,
    username   VARCHAR(50)           NOT NULL,
    password   VARCHAR(50)           NOT NULL,
    role       INT                   NOT NULL,
    permission VARCHAR(255) DEFAULT NULL,
    CONSTRAINT i_username UNIQUE (username)
);
COMMENT ON TABLE xxl_job_user IS '系统用户表';
COMMENT ON COLUMN xxl_job_user.username IS '账号';
COMMENT ON COLUMN xxl_job_user.password IS '密码';
COMMENT ON COLUMN xxl_job_user.role IS '角色：0-普通用户、1-管理员';
COMMENT ON COLUMN xxl_job_user.permission IS '权限：执行器ID列表，多个逗号分割';
CREATE TABLE xxl_job_lock
(
    lock_name VARCHAR(50) NOT NULL,
    PRIMARY KEY (lock_name)
);

COMMENT ON COLUMN xxl_job_lock.lock_name IS '锁名称';

INSERT INTO xxl_job_group (id, app_name, title, address_type, address_list, update_time)
VALUES (1, 'xxl-job-executor-sample', '示例执行器', 0, NULL, '2018-11-03 22:21:31');

INSERT INTO xxl_job_info (id,
                          job_group,
                          job_desc,
                          add_time,
                          update_time,
                          author,
                          alarm_email,
                          schedule_type,
                          schedule_conf,
                          misfire_strategy,
                          executor_route_strategy,
                          executor_handler,
                          executor_param,
                          executor_block_strategy,
                          executor_timeout,
                          executor_fail_retry_count,
                          glue_type,
                          glue_source,
                          glue_remark,
                          glue_updatetime,
                          child_jobid)
VALUES (1,
        1,
        '测试任务1',
        '2018-11-03 22:21:31',
        '2018-11-03 22:21:31',
        'XXL',
        '',
        'CRON',
        '0 0 0 * * ? *',
        'DO_NOTHING',
        'FIRST',
        'demoJobHandler',
        '',
        'SERIAL_EXECUTION',
        0,
        0,
        'BEAN',
        '',
        'GLUE代码初始化',
        '2018-11-03 22:21:31',
        '');
INSERT INTO xxl_job_user (id, username, password, role, permission)
VALUES (1, 'admin', 'e10adc3949ba59abbe56e057f20f883e', 1, NULL);

INSERT INTO xxl_job_lock (lock_name)
VALUES ('schedule_lock');

COMMIT;
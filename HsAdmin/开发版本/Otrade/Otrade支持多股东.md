# 固收业务

## tstp_fund新增银行间id字段

### 加载过程

message.xml
```xml
<message name="fund_info" use_adapter_function="true" function_id="3402129">
    <topic name="fund.jc.920001"/>
</message>
```

data.xml
```xml
<table name="tfund" internal="true">
            <fields>
                <field name="fund_id" type="I" required="true"/>
                <field name="company_id" type="I" />
                <field name="fund_name" type="S" width="128"/>
                <field name="fund_caption" type="S" width="128"/>
                <field name="fund_status" type="C"/>
                <field name="fund_code" type="S" width="16"/>
                <field name="permit_markets" type="S" width="4000"/>
            </fields>
            <indexes>
                <index name="uniq_fund_id" type="I" unique="true" primary="true">
                    <keywords>
                        <keyword name="fund_id"/>
                    </keywords>
                </index>
		<index name="uniq_fund_code" type="S" unique="true">
                    <keywords>
                        <keyword name="company_id" />
						<keyword name="fund_code" />
                    </keywords>
                </index>
            </indexes>
            <loader class="TableLoader_F2" function_id="1402034" type="adapter" sub_system_no="3">
                <request>
                    <field name="subsys_no" value="3" />
                </request>
                <conditions condition_type="datamanger">
                </conditions>
            </loader>
            <!--不回查O3,直接用消息中的数据更新-->
            <updater class="TableUpdater_MC_PB" update_mode="direct">
                <topic name="fund.jc.920001"/>
            </updater>
        </table>
```


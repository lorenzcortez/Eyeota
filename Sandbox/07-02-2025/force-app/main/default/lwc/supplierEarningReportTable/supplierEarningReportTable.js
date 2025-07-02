import { LightningElement } from 'lwc';
const columns = [
    { label: 'Country', fieldName: 'country', wrapText: true, hideDefaultActions: true  },
    { label: 'Organization Name', fieldName: 'name', wrapText: true, hideDefaultActions: true  },
    { label: 'Category', fieldName: 'category', wrapText: true, hideDefaultActions: true  },
    { label: 'Segment Name', fieldName: 'segmentName', wrapText: true, hideDefaultActions: true  },
    { label: 'Gross Earnings (USD)', fieldName: 'grossEarning', type: 'currency', wrapText: true, hideDefaultActions: true  },
    { label: 'Net Earnings (USD)', fieldName: 'netEarningUSD', type: 'currency', wrapText: true, hideDefaultActions: true  },
    { label: 'Net Earnings', fieldName: 'netEarning', type: 'currency', wrapText: true, hideDefaultActions: true  },
    { label: 'Segment Key', fieldName: 'segmentKey', wrapText: true, hideDefaultActions: true  },
];

export default class SupplierEarningReportTable extends LightningElement {
    data = [];
    columns = columns;

    connectedCallback() {
        const data = this.generateData({ amountOfRecords: 100 });
        this.data = data;
    }

    generateData({ amountOfRecords }) {
        return [...Array(amountOfRecords)].map((_, index) => {
            return {
                name : `Name (${index})`,
                country: `Country (${index})`,
                category: `Category (${index})`,
                segmentName: `Segment Name (${index})`,
                grossEarning: Math.floor(Math.random() * 100),
                netEarningUSD: Math.floor(Math.random() * 1000),
                netEarning: Math.floor(Math.random() * 10000),
                segmentKey: `${index}`
            };
        });
    }
}